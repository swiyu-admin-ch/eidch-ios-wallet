import BITCredentialShared
import BITOpenID
import BITTheming
import Factory
import Foundation
import SwiftUI

public class DeferredCredentialViewModel: CredentialCellViewModelProtocol, CredentialViewModelProtocol {

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

  #warning("Update all those computed properties in a follow-up story")

  public var statusText: String {
    switch credential.progressionState {
    case .inProgress:
      "In progress"
    case .invalid:
      "Invalid"
    }
  }

  public var statusImage: Image {
    switch credential.progressionState {
    case .inProgress:
      Image(systemName: "clock")
    case .invalid:
      Assets.statusInvalid.swiftUIImage
    }
  }

  public var statusTextAlt: String {
    switch credential.progressionState {
    case .inProgress:
      "In progress"
    case .invalid:
      "Invalid"
    }
  }

  public var statusBadgeStyle: any BadgeStyle {
    switch credential.progressionState {
    case .inProgress:
      .outline
    case .invalid:
      .error
    }
  }

  public var statusColor: Color {
    switch credential.progressionState {
    case .inProgress: ThemingAssets.Label.secondary.swiftUIColor
    case .invalid: ThemingAssets.Brand.Core.swissRed.swiftUIColor
    }
  }

  public func view() -> some View {
    DeferredCredentialCell(self)
  }

  // MARK: Private

  @Injected(\.getCredentialDisplayUseCase) private var getCredentialDisplayUseCase: GetCredentialDisplayUseCaseProtocol

}
