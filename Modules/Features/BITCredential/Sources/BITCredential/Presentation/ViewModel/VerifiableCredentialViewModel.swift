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
    guard credential.progressionState == .accepted else { return L10n.tkCredentialProgressionStateUnaccepted }
    return selectedCredentialStatus.statusText(validFrom: credential.validFrom, currentDate: currentDate, calendar: calendar)
  }

  public var statusTextAlt: String {
    selectedCredentialStatus.statusTextAlt(validFrom: credential.validFrom, currentDate: currentDate, calendar: calendar)
  }

  public var statusImage: Image {
    guard credential.progressionState == .accepted else { return Assets.statusReadyToAdd.swiftUIImage }
    return selectedCredentialStatus.statusImage
  }

  public var statusBadgeStyle: BadgeStyle {
    guard credential.progressionState == .accepted else { return .success }
    return selectedCredentialStatus.statusBadgeStyle
  }

  public var statusBadgeType: BadgeType {
    credential.progressionState == .accepted ? .plain(statusBadgeStyle) : .filled(statusBadgeStyle)
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

}

// MARK: Equatable

extension VerifiableCredentialViewModel: Equatable {

  nonisolated public static func == (lhs: VerifiableCredentialViewModel, rhs: VerifiableCredentialViewModel) -> Bool {
    lhs.credential == rhs.credential &&
      lhs.environment == rhs.environment &&
      lhs.credentialDisplay == rhs.credentialDisplay &&
      lhs.issuerDisplay == rhs.issuerDisplay &&
      lhs.id == rhs.id &&
      lhs.colorScheme == rhs.colorScheme
  }
}
