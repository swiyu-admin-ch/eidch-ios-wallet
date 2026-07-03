import BITCredential
import BITCredentialShared
import BITNavigation
import Factory
import NavigatorUI
import SwiftUI

@MainActor
@Observable
final class CredentialOfferViewModel {

  // MARK: Lifecycle

  init(credential: VerifiableCredential, trustInformation: TrustInformation? = nil, state: CredentialOfferViewModel.State = .loading) {
    self.credential = credential
    self.trustInformation = trustInformation
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

  var state: State
  var credentialViewModel: VerifiableCredentialViewModel?
  var isUnknownIssuerAlertShown = false
  var destination: InvitationDestinations?

  var isOfferAccepted = false
  var isOfferDeclined = false

  func onAppear() async {
    do {
      if trustInformation == nil {
        trustInformation = try await fetchIssuanceTrustInformationUseCase(for: credential)
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
    do {
      state = .loading

      try await acceptCredentialUseCase(credential)
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

  func accept() async {
    if trustInformation?.identity != .unknown {
      await confirmAccept()
    } else {
      isUnknownIssuerAlertShown = true
    }
  }

  func decline() {
    state = .decline
  }

  func cancelDecline() {
    state = .result
  }

  func openWrongData() {
    destination = .wrongData
  }

  // MARK: Private

  @ObservationIgnored @Injected(\.deleteCredentialUseCase) private var deleteCredentialUseCase: DeleteCredentialUseCaseProtocol
  @ObservationIgnored @Injected(\.acceptCredentialUseCase) private var acceptCredentialUseCase: AcceptCredentialUseCaseProtocol
  @ObservationIgnored @Injected(\.fetchIssuanceTrustInformationUseCase) private var fetchIssuanceTrustInformationUseCase: FetchIssuanceTrustInformationUseCaseProtocol

}
