import BITCredential
import BITCredentialShared
import Factory
import SwiftUI

@MainActor
final class CredentialOfferViewModel: ObservableObject {

  // MARK: Lifecycle

  init(credential: VerifiableCredential, trustInformation: TrustInformation? = nil, state: CredentialOfferViewModel.State = .loading, router: CredentialOfferInternalRoutes) {
    self.credential = credential
    self.trustInformation = trustInformation
    self.state = state
    self.router = router
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

  @Published var state: State
  @Published var credentialViewModel: VerifiableCredentialViewModel?
  @Published var isUnknownIssuerAlertShown = false

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
      try? await Task.sleep(nanoseconds: delayAfterAcceptingCredential)
      close()
    } catch {
      state = .error
    }
  }

  func confirmDecline() async {
    do {
      try await deleteCredentialUseCase.execute(credential)
      close()
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
    router.wrongData()
  }

  // MARK: Private

  private let router: CredentialOfferInternalRoutes

  @Injected(\.delayAfterAcceptingCredential) private var delayAfterAcceptingCredential: UInt64
  @Injected(\.deleteCredentialUseCase) private var deleteCredentialUseCase: DeleteCredentialUseCaseProtocol
  @Injected(\.acceptCredentialUseCase) private var acceptCredentialUseCase: AcceptCredentialUseCaseProtocol
  @Injected(\.fetchIssuanceTrustInformationUseCase) private var fetchIssuanceTrustInformationUseCase: FetchIssuanceTrustInformationUseCaseProtocol

  private func close() {
    router.close()
  }

}
