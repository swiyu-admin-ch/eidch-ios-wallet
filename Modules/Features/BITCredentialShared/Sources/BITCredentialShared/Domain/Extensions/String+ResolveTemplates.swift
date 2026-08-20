import BITClaimsPathPointer
import BITEntities
import Foundation
import RegexBuilder

extension String {

  // MARK: Public

  public func resolvePathTemplates(using clusters: [CredentialClaimClusterEntity], indices: [Int] = []) -> String {
    let allClaims = clusters.flatMap(\.allClaims)
    return replacing(Self.regex) { match in
      guard
        let templatePath = match[Self.pathReference],
        let path = ClaimsPathPointer(templatePath)
      else { return "" }
      let resolvedPath = path.resolveNullElement(with: indices)
      let claims = allClaims.filter({
        guard let claimPath = ClaimsPathPointer($0.path) else { return false }
        return resolvedPath.pointsAtSetOf(claimPath, enforceLength: true)
      })
      let separator = match[Self.joinReference] ?? ", "
      return claims.map(CredentialClaim.init).map(\.localizedValue).joined(separator: separator)
    }
  }

  public func resolvePathTemplates(using clusters: [CredentialClaimCluster], indices: [Int] = []) -> String {
    let allClaims = clusters.flatMap(\.allClaims)
    return replacing(Self.regex) { match in
      guard
        let templatePath = match[Self.pathReference],
        let path = ClaimsPathPointer(templatePath)
      else { return "" }
      let resolvedPath = path.resolveNullElement(with: indices)
      let claims = allClaims.filter({
        resolvedPath.pointsAtSetOf($0.path, enforceLength: true)
      })
      let separator = match[Self.joinReference] ?? ", "
      return claims.map(\.localizedValue).joined(separator: separator)
    }
  }

  // MARK: Private

  private static let pathReference = Reference(String?.self)
  private static let joinReference = Reference(String?.self)
  private static let quoteReference = Reference(Substring.self)

  private static let regex = Regex {
    "{{"
    Capture(as: pathReference) {
      ZeroOrMore(.any, .reluctant)
    } transform: { String($0) }
    Optionally(joinRegex)
    "}}"
  }

  private static let joinRegex = Regex {
    ".join("
    Capture(as: quoteReference) {
      ChoiceOf {
        "'"
        "\""
      }
    }
    Capture(as: joinReference) {
      Repeat(0...10) {
        NegativeLookahead { quoteReference }
        CharacterClass.any
      }
    } transform: { String($0) }
    quoteReference
    ")"
  }
}

extension CredentialClaimClusterEntity {
  fileprivate var allClaims: [CredentialClaimEntity] {
    claims + childClusters.flatMap(\.allClaims)
  }
}

extension CredentialClaimCluster {
  fileprivate var allClaims: [CredentialClaim] {
    claims + childClusters.flatMap(\.allClaims)
  }
}
