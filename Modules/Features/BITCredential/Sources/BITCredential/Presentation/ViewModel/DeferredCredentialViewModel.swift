import BITCredentialShared
import BITL10n
import BITOpenID
import BITTheming
import Factory
import Foundation
import SwiftUI

public class DeferredCredentialViewModel: CredentialCardViewModelProtocol, CredentialViewModelProtocol {

  // MARK: Lifecycle

  public required init(credential: DeferredCredential, colorScheme: String = String()) {
    id = credential.id
    self.credential = credential
    issuerDisplay = credential.issuerDisplays.findDisplayWithFallback()
    credentialDisplay = getCredentialDisplayUseCase.execute(for: credential.displays, colorScheme: colorScheme)
  }

  // MARK: Public

  public let id: UUID
  public let credential: DeferredCredential
  public let issuerDisplay: CredentialIssuerDisplay?
  public var credentialDisplay: CredentialDisplay?
  public var environment: TrustEnvironment?

  public var statusText: String {
    switch credential.progressionState {
    case .inProgress: L10n.tkDeferredCredentialStatusInProgress
    case .invalid: L10n.tkDeferredCredentialStatusInvalid
    }
  }

  public var statusImage: Image {
    switch credential.progressionState {
    case .inProgress:
      Image(systemName: "clock")
    case .invalid:
      Image(systemName: "xmark")
    }
  }

  public var statusBadgeAccessibilityText: String {
    statusText
  }

  public var statusTextAlt: String {
    switch credential.progressionState {
    case .inProgress: L10n.tkDeferredCredentialStatusInProgress
    case .invalid: L10n.tkDeferredCredentialStatusInvalid
    }
  }

  public var cardStatusBadgeStyle: any BadgeStyle {
    credential.progressionState == .inProgress ? .info : .error
  }

  public var statusBadgeStyle: any BadgeStyle {
    .info
  }

  public var statusColor: Color {
    ThemingAssets.Label.secondary.swiftUIColor
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
