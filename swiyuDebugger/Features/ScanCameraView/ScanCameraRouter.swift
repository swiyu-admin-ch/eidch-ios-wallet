import BITCredential
import BITCredentialShared
import BITInvitation
import BITNavigation
import BITPresentation
import Foundation

// MARK: - ScanCameraRouter

@MainActor
final class ScanCameraRouter: ObservableObject, InvitationRouterRoutes {

  @Published var route: ScanCameraRoute?
  var onClose: (() -> Void)?

  func credentialOffer(credential: VerifiableCredential, trustInformation: TrustInformation?, delegate: InvitationDelegate?) {
    route = ScanCameraRoute(destination: .credential(credential, trustInformation))
  }

  func startPresentation(context: PresentationRequestContext, delegate: PresentationFinishDelegate?) throws {
    route = ScanCameraRoute(destination: .presentation(context))
  }

  func close(onComplete: (() -> Void)?) {
    onClose?()
    onComplete?()
  }

  func close() {
    onClose?()
  }

  func pop() {
  }

  func pop(count: Int) {
  }

  func popToRoot() {
  }

  func dismiss() {
    onClose?()
  }

  func invitation(delegate: InvitationDelegate?) {}

  func deeplink(url: URL, animated: Bool) -> Bool {
    false
  }

  func camera(openingStyle: OpeningStyle, delegate: InvitationDelegate?) {}

  func betaId() {}

  func externalSettings() {}

  func openExternalLink(url: URL) {}

  func openExternalLink(url: URL, onComplete: (() -> Void)?) {
    onComplete?()
  }

  func login(animated: Bool) {}
}

// MARK: - ScanCameraRoute

struct ScanCameraRoute: Hashable {
  enum Destination {
    case credential(VerifiableCredential, TrustInformation?)
    case presentation(PresentationRequestContext)
  }

  let id = UUID()
  let destination: Destination

  static func == (lhs: ScanCameraRoute, rhs: ScanCameraRoute) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

// MARK: - ScanCameraErrorRoute

struct ScanCameraErrorRoute: Hashable {
  let id = UUID()
  let error: Error

  static func == (lhs: ScanCameraErrorRoute, rhs: ScanCameraErrorRoute) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
