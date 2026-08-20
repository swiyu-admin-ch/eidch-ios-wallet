import Factory
import Foundation

/// A regular expression, backed by `NSRegularExpression`, that enforces a hard wall-clock
/// limit on evaluation.
///
/// Unlike Swift's `Regex`, `NSRegularExpression` exposes a cooperative cancellation hook
/// (`NSRegularExpression.MatchingOptions.reportProgress`): it invokes the enumeration block
/// periodically during long-running matches — including deep inside backtracking. We use that to
/// abort a runaway evaluation once `timeout` elapses, so a malicious input can no longer leak a
/// thread that spins a CPU core to completion (the failure mode of the previous, thread-abandoning
/// implementation).
///
/// The pattern is always a compile-time constant string literal; a malformed literal traps, since
/// that is a programmer error rather than a runtime condition.
public struct TimeLimitedRegex: ExpressibleByStringLiteral {

  // MARK: Lifecycle

  public init(stringLiteral pattern: String) {
    guard let regex = try? NSRegularExpression(pattern: pattern) else {
      fatalError("Invalid regular expression literal: \(pattern)")
    }
    self.regex = regex
  }

  // MARK: Public

  /// Returns `true` if the entire `string` matches, anchored at both ends.
  /// Throws `RegexEvaluationError.timeout` if the evaluation does not complete within `Container.shared.regexEvaluationTimeout`.
  public func wholeMatch(in string: String) throws -> Bool {
    try evaluate(in: string, shouldMatchWholeString: true)
  }

  /// Returns `true` if `string` contains a match anywhere.
  /// Throws `RegexEvaluationError.timeout` if the evaluation does not complete within `Container.shared.regexEvaluationTimeout`.
  public func firstMatch(in string: String) throws -> Bool {
    try evaluate(in: string, shouldMatchWholeString: false)
  }

  // MARK: Private

  private let regex: NSRegularExpression

  private func evaluate(in string: String, shouldMatchWholeString: Bool) throws -> Bool {
    let entireRange = NSRange(string.startIndex..., in: string)
    let timeout = Container.shared.regexEvaluationTimeout()
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: .seconds(timeout))

    var matchingOptions: NSRegularExpression.MatchingOptions = [.reportProgress]
    if shouldMatchWholeString { matchingOptions.insert(.anchored) }

    var foundMatch = false
    var matchError: Error? = nil

    regex.enumerateMatches(in: string, options: matchingOptions, range: entireRange) { match, flags, stop in
      do {
        try handleTimeout(clock, deadline, flags, stop)
        foundMatch = handleMatch(match, shouldMatchWholeString, entireRange, stop)
      } catch {
        matchError = error
      }
    }

    if let matchError { throw matchError }
    return foundMatch
  }

  private func handleTimeout(
    _ clock: ContinuousClock,
    _ deadline: ContinuousClock.Instant,
    _ flags: NSRegularExpression.MatchingFlags,
    _ stop: UnsafeMutablePointer<ObjCBool>) throws
  {
    let isProgressUpdate = flags.contains(.progress)
    let isTimedOut = clock.now >= deadline

    guard isProgressUpdate, isTimedOut else { return }
    stop.pointee = true
    throw RegexEvaluationError.timeout
  }

  private func handleMatch(
    _ match: NSTextCheckingResult?,
    _ shouldMatchWholeString: Bool,
    _ entireRange: NSRange,
    _ stop: UnsafeMutablePointer<ObjCBool>)
    -> Bool
  {
    guard let match else { return false }
    stop.pointee = true
    return shouldMatchWholeString ? (match.range == entireRange) : true
  }
}
