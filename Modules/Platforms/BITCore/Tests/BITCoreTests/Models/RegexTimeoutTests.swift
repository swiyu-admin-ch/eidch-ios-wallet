import FactoryTesting
import Testing
@testable import BITCore

@Suite(.container)
struct RegexTimeoutTests {

  @Test
  func wholeMatch_matchingInput_returnsTrue() throws {
    let regex: TimeLimitedRegex = "[a-z]+"

    #expect(try regex.wholeMatch(in: "hello"))
  }

  @Test
  func wholeMatch_nonMatchingInput_returnsFalse() throws {
    let regex: TimeLimitedRegex = "[a-z]+"

    #expect(try regex.wholeMatch(in: "hello world 42") == false)
  }

  @Test
  func firstMatch_matchingInput_returnsTrue() throws {
    let regex: TimeLimitedRegex = "[a-z]+"

    #expect(try regex.firstMatch(in: "42 hello"))
  }

  @Test
  func firstMatch_nonMatchingInput_returnsFalse() throws {
    let regex: TimeLimitedRegex = "[a-z]+"

    #expect(try regex.firstMatch(in: "42 84") == false)
  }

  @Test
  func wholeMatch_catastrophicBacktracking_throwsTimeout() {
    // Evil pattern: nested quantifiers over the same characters backtrack
    // exponentially on non-matching input.
    let evilRegex: TimeLimitedRegex = "(a+)+b"
    let payload = String(repeating: "a", count: 64) + "c"

    #expect(throws: RegexEvaluationError.timeout) {
      try evilRegex.wholeMatch(in: payload)
    }
  }

  @Test
  func firstMatch_catastrophicBacktracking_throwsTimeout() {
    let evilRegex: TimeLimitedRegex = "(a+)+b"
    let payload = String(repeating: "a", count: 64) + "c"

    #expect(throws: RegexEvaluationError.timeout) {
      try evilRegex.firstMatch(in: payload)
    }
  }
}
