import Alamofire
import BITCore
import Foundation

// MARK: - WildcardServerTrustManager

/// A custom `ServerTrustManager` that supports wildcard domain matching.
open class WildcardServerTrustManager: ServerTrustManager, @unchecked Sendable {

  // MARK: Public

  /// Returns a `ServerTrustEvaluating` object for a given host.
  /// Returns `nil` if no evaluators has been configured for this host domain.
  ///
  /// - Parameter host: The host for which to return the evaluator.
  /// - Returns: A `ServerTrustEvaluating` object if found.
  public override func serverTrustEvaluator(forHost host: String) throws -> ServerTrustEvaluating? {
    if let exactEvaluation = evaluators[host] {
      return exactEvaluation
    }
    guard
      let rootDomain = getWildcardRootDomain(from: host),
      let subdomainEvaluation = evaluators[rootDomain] else
    {
      return nil
    }
    return subdomainEvaluation
  }

  // MARK: Private

  /// Returns the `wildcard root domain` from a given host.
  /// Returns `nil` if no keys has been registered for this host domain.
  ///
  /// - Parameter host: The host from which to extract the root domain.
  /// - Returns: A wildcard root domain string if found.
  private func getWildcardRootDomain(from host: String) -> String? {
    let keys = evaluators.keys.map { String($0) }
    return Self.getMatchingPattern(url: host, patterns: keys)
  }

}

extension WildcardServerTrustManager {
  private static func getMatchingPattern(url: String, patterns: [String]) -> String? {
    for pattern in patterns {
      let regexPattern = pattern
        .replacingOccurrences(of: ".", with: "\\.")
        .replacingOccurrences(of: "*", with: ".*")

      guard let regex = try? Regex(regexPattern), url.contains(regex) else { continue }
      return pattern
    }
    return nil
  }
}
