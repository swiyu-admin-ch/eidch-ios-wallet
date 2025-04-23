import BITCore
import BITCredentialShared
import BITL10n
import BITOpenID
import BITTheming
import SwiftUI

extension Credential {

  // MARK: Public

  public var statusText: String {
    switch status {
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
    switch status {
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
    switch status {
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
    switch status {
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
    switch status {
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
    guard let date = validFrom else { return L10n.tkCredentialStatusUnknown }
    return if date.isWithinNext24Hours {
      L10n.tkCredentialStatusSoon
    } else if let days = date.numberOfDaysSince(Date()) {
      L10n.tkCredentialStatusNotValidYet(days)
    } else {
      L10n.tkCredentialStatusUnknown
    }
  }

  private func getNotYetValidAltText() -> String {
    guard let date = validFrom else { return L10n.tkCredentialStatusUnknown }
    return if date.isWithinNext24Hours {
      L10n.tkCredentialStatusSoonAlt
    } else if let days = date.numberOfDaysSince(Date()) {
      L10n.tkCredentialStatusNotValidYetAlt(days)
    } else {
      L10n.tkCredentialStatusUnknownAlt
    }
  }
}
