import BITCredential
import BITCredentialShared
import BITNavigation
import BITNonCompliance
import Factory
import NavigatorUI
import SwiftUI

@MainActor
@Observable
final class CredentialOfferViewModel {

  // MARK: Lifecycle

  init(credential: VerifiableCredential, state: CredentialOfferViewModel.State = .loading) {
    self.credential = credential
    self.state = state
  }

  // MARK: Internal

  enum State: Equatable {
    case result
    case loading
    case decline
    case error
  }

  let credential: VerifiableCredential
  var trustInformation: TrustInformation?
  var actorCompliance = ActorCompliance.compliant

  var state: State
  var credentialViewModel: VerifiableCredentialViewModel?
  var alert: CredentialOfferAlert?
  var destination: InvitationDestinations?

  var isOfferAccepted = false
  var isOfferDeclined = false

  func onAppear() async {
    do {
      if trustInformation == nil {
        let (trustInformation, actorCompliance) = try await fetchIssuanceTrustInformationUseCase(for: credential)
        self.trustInformation = trustInformation
        self.actorCompliance = actorCompliance
      }

      state = .result
    } catch {
      state = .error
    }
  }

  func updateCredentialViewModel(with colorScheme: String) {
    credentialViewModel = VerifiableCredentialViewModel(credential: credential, colorScheme: colorScheme)
  }

  func confirmAccept() async {
    guard let trustInformation else {
      state = .error
      return
    }
    do {
      state = .loading

      try await acceptCredentialUseCase(credential, trustInformation: trustInformation, actorCompliance: actorCompliance)
      isOfferAccepted = true
    } catch {
      state = .error
    }
  }

  func confirmDecline() async {
    do {
      try await deleteCredentialUseCase.execute(credential)
      isOfferDeclined = true
    } catch {
      state = .error
    }
  }

  func accept(force: Bool = false) async {
    alert = nil

    if !force, case .notCompliant = actorCompliance {
      alert = .nonCompliantActor
    } else if force || trustInformation?.identity != .unknown {
      await confirmAccept()
    } else {
      alert = .unknownIssuer
    }
  }

  func decline() {
    state = .decline
  }

  func cancelDecline() {
    state = .result
  }

  // MARK: Private

  @ObservationIgnored @Injected(\.deleteCredentialUseCase) private var deleteCredentialUseCase: DeleteCredentialUseCaseProtocol
  @ObservationIgnored @Injected(\.acceptCredentialUseCase) private var acceptCredentialUseCase: AcceptCredentialUseCaseProtocol
  @ObservationIgnored @Injected(\.fetchIssuanceTrustInformationUseCase) private var fetchIssuanceTrustInformationUseCase: FetchIssuanceTrustInformationUseCaseProtocol

}
