import BITCredentialShared
import BITL10n
import BITTheming
import RegexBuilder
import SwiftUI

// MARK: - CredentialViewModel

public class CredentialViewModel: Identifiable {

  // MARK: Lifecycle

  public init(credential: VerifiableCredential, credentialDisplay: CredentialDisplay?) {
    self.credential = credential
    environment = credential.environment
    issuerDisplay = credential.issuerDisplays.findDisplayWithFallback()
    id = credential.id
    let claims = credential.clusters.flatMap(\.claims)
    self.credentialDisplay = credentialDisplay?.resolveClaimTemplate(with: claims)
  }

  // MARK: Public

  public let credential: VerifiableCredential
  public let environment: CredentialEnvironment?
  public var credentialDisplay: CredentialDisplay?
  public let issuerDisplay: CredentialIssuerDisplay?
  public let id: UUID

  public var statusText: String {
    switch credential.status {
    case .valid: L10n.tkCredentialStatusValid
    case .expired: L10n.tkCredentialStatusInvalid
    case .notYetValid: getNotYetValidText()
    case .revoked: L10n.tkCredentialStatusRevoked
    case .suspended: L10n.tkCredentialStatusSuspended
    case .unknown,
         .unsupported: L10n.tkCredentialStatusUnknown
    }
  }

  public var statusTextAlt: String {
    switch credential.status {
    case .valid: L10n.tkCredentialStatusValidAlt
    case .expired: L10n.tkCredentialStatusInvalidAlt
    case .notYetValid: getNotYetValidAltText()
    case .revoked: L10n.tkCredentialStatusRevokedAlt
    case .suspended: L10n.tkCredentialStatusSuspendedAlt
    case .unknown,
         .unsupported: L10n.tkCredentialStatusUnknownAlt
    }
  }

  public var statusImage: Image {
    switch credential.status {
    case .valid: Assets.statusValid.swiftUIImage
    case .expired: Assets.statusInvalid.swiftUIImage
    case .notYetValid: Assets.statusNotYetValid.swiftUIImage
    case .revoked: Assets.statusInvalid.swiftUIImage
    case .suspended: Assets.statusSuspended.swiftUIImage
    case .unknown,
         .unsupported: Assets.statusUnknown.swiftUIImage
    }
  }

  public var statusColor: Color {
    switch credential.status {
    case .unknown,
         .unsupported,
         .valid: ThemingAssets.Label.secondary.swiftUIColor
    case .expired,
         .notYetValid,
         .revoked,
         .suspended: ThemingAssets.Brand.Core.swissRed.swiftUIColor
    }
  }

  public var statusBadgeStyle: any BadgeStyle {
    switch credential.status {
    case .unknown,
         .unsupported,
         .valid: .outline
    case .expired,
         .notYetValid,
         .revoked,
         .suspended: .error
    }
  }

  // MARK: Private

  private func getNotYetValidText() -> String {
    guard let date = credential.validFrom else { return L10n.tkCredentialStatusUnknown }
    return if date.isWithinNext24Hours {
      L10n.tkCredentialStatusSoon
    } else if let days = date.numberOfDaysSince(Date()) {
      L10n.tkCredentialStatusNotValidYet(days)
    } else {
      L10n.tkCredentialStatusUnknown
    }
  }

  private func getNotYetValidAltText() -> String {
    guard let date = credential.validFrom else { return L10n.tkCredentialStatusUnknown }
    return if date.isWithinNext24Hours {
      L10n.tkCredentialStatusSoonAlt
    } else if let days = date.numberOfDaysSince(Date()) {
      L10n.tkCredentialStatusNotValidYetAlt(days)
    } else {
      L10n.tkCredentialStatusUnknownAlt
    }
  }
}

extension CredentialDisplay {

  // MARK: Public

  public func resolveClaimTemplate(with claims: [CredentialClaim]) -> Self {
    var copy = self

    copy.summary = summary?.replacing(Self.regex) { match in
      guard let claim = claims.first(where: { match.1 == "$.\($0.key)" }) else { return "" }
      return claim.value ?? "–"
    }
    return copy
  }

  // MARK: Private

  private static let regex = Regex {
    "{{"
    Capture {
      ZeroOrMore(.any, .reluctant)
    }
    "}}"
  }

}
