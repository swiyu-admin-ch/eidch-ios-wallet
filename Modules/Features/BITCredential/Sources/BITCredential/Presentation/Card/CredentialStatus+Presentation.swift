import BITCore
import BITCredentialShared
import BITL10n
import BITTheming
import SwiftUI

extension CredentialStatus {

  // MARK: Public

  public var statusImage: Image {
    switch self {
    case .valid: Assets.statusValid.swiftUIImage
    case .businessExpired,
         .expired: Assets.statusInvalid.swiftUIImage
    case .notYetValid: Assets.statusNotYetValid.swiftUIImage
    case .revoked: Assets.statusInvalid.swiftUIImage
    case .suspended: Assets.statusSuspended.swiftUIImage
    case .unknown,
         .unsupported: Assets.statusUnknown.swiftUIImage
    }
  }

  public var statusBadgeStyle: BadgeStyle {
    switch self {
    case .valid: .success
    case .notYetValid,
         .unknown,
         .unsupported: .info
    case .businessExpired,
         .expired,
         .revoked,
         .suspended: .error
    }
  }

  public func statusText(validFrom: Date? = nil, currentDate: Date = Date(), calendar: Calendar = .current) -> String {
    switch self {
    case .valid: L10n.tkCredentialStatusValid
    case .businessExpired,
         .expired: L10n.tkCredentialStatusInvalid
    case .notYetValid: notYetValidText(validFrom: validFrom, currentDate: currentDate, calendar: calendar)
    case .revoked: L10n.tkCredentialStatusRevoked
    case .suspended: L10n.tkCredentialStatusSuspended
    case .unknown,
         .unsupported: L10n.tkCredentialStatusUnknown
    }
  }

  public func statusTextAlt(validFrom: Date? = nil, currentDate: Date = Date(), calendar: Calendar = .current) -> String {
    switch self {
    case .valid: L10n.tkCredentialStatusValidAlt
    case .businessExpired,
         .expired: L10n.tkCredentialStatusInvalidAlt
    case .notYetValid: notYetValidAltText(validFrom: validFrom, currentDate: currentDate, calendar: calendar)
    case .revoked: L10n.tkCredentialStatusRevokedAlt
    case .suspended: L10n.tkCredentialStatusSuspendedAlt
    case .unknown,
         .unsupported: L10n.tkCredentialStatusUnknownAlt
    }
  }

  // MARK: Private

  private func notYetValidText(validFrom: Date?, currentDate: Date, calendar: Calendar) -> String {
    guard let validFrom else { return L10n.tkCredentialStatusUnknown }
    return if calendar.isDate(validFrom, inSameDayAs: currentDate) {
      L10n.tkCredentialStatusValidAt(DateFormatter.shortHourFormatter.string(from: validFrom))
    } else {
      L10n.tkCredentialStatusNotYetValid(DateFormatter.shortDateFormatter.string(from: validFrom))
    }
  }

  private func notYetValidAltText(validFrom: Date?, currentDate: Date, calendar: Calendar) -> String {
    guard let validFrom else { return L10n.tkCredentialStatusUnknownAlt }
    return if calendar.isDate(validFrom, inSameDayAs: currentDate) {
      L10n.tkCredentialStatusValidAtAlt(DateFormatter.shortHourFormatter.string(from: validFrom))
    } else {
      L10n.tkCredentialStatusNotYetValidAlt(DateFormatter.shortDateFormatter.string(from: validFrom))
    }
  }
}
