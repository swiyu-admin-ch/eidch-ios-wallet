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

  init(credential: Credential, trustStatement: TrustStatement? = nil, state: CredentialOfferViewModel.State = .result, router: CredentialOfferInternalRoutes) {
    self.credential = credential
    self.trustStatement = trustStatement
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
    case decline
    case openWrongData
    case confirmDecline
    case cancelDecline
    case onError(Error)
    case close

    case none
  }

  let credential: Credential

  @Published var issuerDisplay: CredentialIssuerDisplay?
  @Published var credentialViewModel: CredentialViewModel?

  var issuerTrustStatus: TrustStatus {
    (trustStatement != nil) ? .verified : .unverified
  }

  override func reducer(_ state: inout State, _ event: Event) -> AnyPublisher<Event, Never>? {
    switch event {
    case .accept:
      withAnimation {
        state = .loading
        Task {
          try? await Task.sleep(nanoseconds: delayAfterAcceptingCredential)
          router.close()
        }
      }
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
    let display = getCredentialDisplayUseCase.execute(for: credential.displays, colorScheme: colorScheme)
    credentialViewModel = CredentialViewModel(credential: credential, credentialDisplay: display)

    guard let trustStatement else {
      issuerDisplay = credentialViewModel?.issuerDisplay
      return
    }

    issuerDisplay = getCredentialIssuerDisplayUseCase.execute(for: credential.id, trustStatement: trustStatement, fallbackDisplay: credentialViewModel?.issuerDisplay)
  }

  // MARK: Private

  private let router: CredentialOfferInternalRoutes
  private var trustStatement: TrustStatement?
  @Injected(\.delayAfterAcceptingCredential) private var delayAfterAcceptingCredential: UInt64
  @Injected(\.deleteCredentialUseCase) private var deleteCredentialUseCase: DeleteCredentialUseCaseProtocol
  @Injected(\.getCredentialIssuerDisplayUseCase) private var getCredentialIssuerDisplayUseCase: GetCredentialIssuerDisplayUseCaseProtocol
  @Injected(\.getCredentialDisplayUseCase) private var getCredentialDisplayUseCase: GetCredentialDisplayUseCaseProtocol

}
