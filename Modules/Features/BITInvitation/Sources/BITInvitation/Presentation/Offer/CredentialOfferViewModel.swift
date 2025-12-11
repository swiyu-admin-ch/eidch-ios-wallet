import BITCore
import BITCredential
import BITCredentialShared
import BITOpenID
import Combine
import Factory
import SwiftUI

// MARK: - CredentialOfferViewModel

@MainActor
final class CredentialOfferViewModel: StateMachine<CredentialOfferViewModel.State, CredentialOfferViewModel.Event> {

  // MARK: Lifecycle

  init(credential: VerifiableCredential, trustInformation: TrustInformation, state: CredentialOfferViewModel.State = .result, router: CredentialOfferInternalRoutes) {
    self.credential = credential
    self.trustInformation = trustInformation
    self.router = router
    super.init(state)
  }

  // MARK: Internal

  enum State: Equatable {
    case result
    case loading
    case decline
    case error
  }

  enum Event {
    case accept
    case confirmAccept
    case decline
    case openWrongData
    case confirmDecline
    case cancelDecline
    case onError(Error)
    case close

    case none
  }

  let credential: VerifiableCredential
  let trustInformation: TrustInformation

  @Published var credentialViewModel: VerifiableCredentialViewModel?
  @Published var isUnknownIssuerAlertShown = false

  override func reducer(_ state: inout State, _ event: Event) -> AnyPublisher<Event, Never>? {
    switch event {
    case .accept:
      if trustInformation.identity != .unknown {
        accept(&state)
      } else {
        isUnknownIssuerAlertShown = true
      }
    case .confirmAccept:
      accept(&state)
    case .decline:
      state = .decline
    case .openWrongData:
      router.wrongData()
    case .confirmDecline:
      return AnyPublisher.run {
        try await self.deleteCredentialUseCase.execute(self.credential)
      } onSuccess: { _ in
        .close
      } onError: { error in
        .onError(error)
      }
    case .cancelDecline:
      state = .result
    case .onError(let error):
      stateError = error
      state = .error
    case .close:
      router.close()
    default: break
    }

    return nil
  }

  func updateCredentialViewModel(with colorScheme: String) {
    credentialViewModel = VerifiableCredentialViewModel(credential: credential, colorScheme: colorScheme)
  }

  // MARK: Private

  private let router: CredentialOfferInternalRoutes
  @Injected(\.delayAfterAcceptingCredential) private var delayAfterAcceptingCredential: UInt64
  @Injected(\.deleteCredentialUseCase) private var deleteCredentialUseCase: DeleteCredentialUseCaseProtocol

  private func accept(_ state: inout State) {
    withAnimation {
      state = .loading
      Task {
        try? await Task.sleep(nanoseconds: delayAfterAcceptingCredential)
        router.close()
      }
    }
  }
}
