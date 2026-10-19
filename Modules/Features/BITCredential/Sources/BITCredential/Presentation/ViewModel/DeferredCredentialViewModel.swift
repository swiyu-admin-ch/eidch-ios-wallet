import BITCredentialShared
import BITL10n
import BITOpenID
import BITTheming
import Factory
import Foundation
import SwiftUI

@MainActor
public class DeferredCredentialViewModel: CredentialCardViewModelProtocol, CredentialViewModelProtocol {

  // MARK: Lifecycle

  public required init(credential: DeferredCredential, colorScheme: String = String()) {
    id = credential.id
    self.credential = credential
    issuerDisplay = credential.issuerDisplays.findDisplayWithFallback()

    let display = getCredentialDisplayUseCase.execute(for: credential.displays, colorScheme: colorScheme)
    credentialDisplay = display?.resolvePathTemplate(with: []) // Set empty claims as they aren't available yet but summary field can still contains a static value
  }

  // MARK: Public

  public let id: UUID
  public let credential: DeferredCredential
  public let issuerDisplay: CredentialIssuerDisplay?
  public var credentialDisplay: CredentialDisplay?
  public var environment: TrustEnvironment?
  public let isRefreshable = false
  public let isBatchPrivacyWarningVisible = false

  public var statusText: String {
    switch credential.progressionState {
    case .inProgress: L10n.tkDeferredCredentialStatusInProgress
    case .invalid: L10n.tkDeferredCredentialStatusInvalid
    case .issuanceFailed: L10n.tkDeferredCredentialStatusIssuanceFailed
    }
  }

  public var statusImage: Image {
    switch credential.progressionState {
    case .inProgress:
      Assets.statusInProgress.swiftUIImage
    case .invalid,
         .issuanceFailed:
      Assets.statusRejected.swiftUIImage
    }
  }

  public var statusTextAlt: String {
    switch credential.progressionState {
    case .inProgress: L10n.tkDeferredCredentialStatusInProgress
    case .invalid: L10n.tkDeferredCredentialStatusInvalid
    case .issuanceFailed: L10n.tkDeferredCredentialStatusIssuanceFailed
    }
  }

  public var statusBadgeStyle: BadgeStyle {
    credential.progressionState == .inProgress ? .info : .error
  }

  public var statusBadgeType: BadgeType {
    .plain(statusBadgeStyle)
  }

  public var cardStyle: CredentialCardStyle {
    .deferred
  }

  public func view() -> some View {
    DeferredCredentialCell(self)
  }

  // MARK: Private

  @Injected(\.getCredentialDisplayUseCase) private var getCredentialDisplayUseCase: GetCredentialDisplayUseCaseProtocol

}
