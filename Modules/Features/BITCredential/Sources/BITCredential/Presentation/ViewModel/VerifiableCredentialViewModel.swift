import BITCore
import BITCredentialShared
import BITL10n
import BITOpenID
import BITTheming
import Factory
import RegexBuilder
import SwiftUI

// MARK: - VerifiableCredentialViewModel

public struct VerifiableCredentialViewModel: CredentialCardViewModelProtocol, CredentialViewModelProtocol {

  // MARK: Lifecycle

  public init(credential: VerifiableCredential, colorScheme: String = String()) {
    self.credential = credential
    environment = credential.environment
    issuerDisplay = credential.issuerDisplays.findDisplayWithFallback()
    id = credential.id
    self.colorScheme = colorScheme

    let display = getCredentialDisplayUseCase.execute(for: credential.displays, colorScheme: colorScheme)
    credentialDisplay = display?.resolvePathTemplate(with: credential.resolvedClusters)
  }

  // MARK: Public

  public let credential: VerifiableCredential
  public let environment: TrustEnvironment?
  public var credentialDisplay: CredentialDisplay?
  public let issuerDisplay: CredentialIssuerDisplay?
  public let id: UUID
  public let colorScheme: String

  public var isRefreshable: Bool {
    credential.authentication.refreshToken != nil
  }

  public var isBatchPrivacyWarningVisible: Bool {
    isBatchIssuanceEnabled &&
      credential.batchData != nil &&
      isRefreshable &&
      !credential.bundleItems.isEmpty &&
      credential.bundleItems.allSatisfy(\.presented)
  }

  public var statusText: String {
    switch selectedCredentialStatus {
    case .valid: L10n.tkCredentialStatusValid
    case .businessExpired,
         .expired: L10n.tkCredentialStatusInvalid
    case .notYetValid: getNotYetValidText()
    case .revoked: L10n.tkCredentialStatusRevoked
    case .suspended: L10n.tkCredentialStatusSuspended
    case .unknown,
         .unsupported: L10n.tkCredentialStatusUnknown
    }
  }

  public var statusTextAlt: String {
    switch selectedCredentialStatus {
    case .valid: L10n.tkCredentialStatusValidAlt
    case .businessExpired,
         .expired: L10n.tkCredentialStatusInvalidAlt
    case .notYetValid: getNotYetValidAltText()
    case .revoked: L10n.tkCredentialStatusRevokedAlt
    case .suspended: L10n.tkCredentialStatusSuspendedAlt
    case .unknown,
         .unsupported: L10n.tkCredentialStatusUnknownAlt
    }
  }

  public var statusImage: Image {
    switch selectedCredentialStatus {
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

  public var statusBadgeAccessibilityText: String {
    switch credential.progressionState {
    case .accepted:
      statusText
    case .unaccepted:
      L10n.tkCredentialProgressionStateUnaccepted
    }
  }

  public var statusColor: Color {
    switch selectedCredentialStatus {
    case .unknown,
         .unsupported,
         .valid: ThemingAssets.Label.secondary.swiftUIColor
    case .businessExpired,
         .expired,
         .notYetValid,
         .revoked,
         .suspended: ThemingAssets.Brand.Core.swissRed.swiftUIColor
    }
  }

  public var cardStatusBadgeStyle: any BadgeStyle {
    statusBadgeStyle
  }

  public var statusBadgeStyle: any BadgeStyle {
    switch selectedCredentialStatus {
    case .unknown,
         .unsupported,
         .valid: .outline
    case .businessExpired,
         .expired,
         .notYetValid,
         .revoked,
         .suspended: .error
    }
  }

  public var cardStyle: CredentialCardStyle {
    .verifiable
  }

  public var issuanceTypeTitle: String {
    credential.bundleItems.count == 1
      ? L10n.tkCredentialIssuanceTypeSingle
      : L10n.tkCredentialIssuanceTypeBatch
  }

  public func view() -> some View {
    VerifiableCredentialCellV1(self)
  }

  // MARK: Private

  @Injected(\.calendar) private var calendar: Calendar
  @Injected(\.currentDate) private var currentDate: Date
  @Injected(\.isBatchIssuanceEnabled) private var isBatchIssuanceEnabled: Bool
  @Injected(\.getCredentialDisplayUseCase) private var getCredentialDisplayUseCase: GetCredentialDisplayUseCaseProtocol
  @Injected(\.selectCredentialBundleItemUseCase) private var selectCredentialBundleItemUseCase: SelectCredentialBundleItemUseCaseProtocol

  private var selectedCredentialStatus: CredentialStatus {
    (try? selectCredentialBundleItemUseCase(credential).status) ?? CredentialStatus.unknown
  }

  private func getNotYetValidText() -> String {
    guard let date = credential.validFrom else { return L10n.tkCredentialStatusUnknown }
    return if calendar.isDate(date, inSameDayAs: currentDate) {
      L10n.tkCredentialStatusValidAt(DateFormatter.shortHourFormatter.string(from: date))
    } else {
      L10n.tkCredentialStatusNotYetValid(DateFormatter.shortDateFormatter.string(from: date))
    }
  }

  private func getNotYetValidAltText() -> String {
    guard let date = credential.validFrom else { return L10n.tkCredentialStatusUnknownAlt }
    return if calendar.isDate(date, inSameDayAs: currentDate) {
      L10n.tkCredentialStatusValidAtAlt(DateFormatter.shortHourFormatter.string(from: date))
    } else {
      L10n.tkCredentialStatusNotYetValidAlt(DateFormatter.shortDateFormatter.string(from: date))
    }
  }
}

// MARK: Equatable

extension VerifiableCredentialViewModel: Equatable {

  public static func == (lhs: VerifiableCredentialViewModel, rhs: VerifiableCredentialViewModel) -> Bool {
    lhs.credential == rhs.credential &&
      lhs.environment == rhs.environment &&
      lhs.credentialDisplay == rhs.credentialDisplay &&
      lhs.issuerDisplay == rhs.issuerDisplay &&
      lhs.id == rhs.id &&
      lhs.colorScheme == rhs.colorScheme
  }
}
