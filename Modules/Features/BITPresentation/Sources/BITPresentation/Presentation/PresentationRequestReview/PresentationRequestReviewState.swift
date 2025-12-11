import BITCore
import BITCredential
import BITCredentialShared

// MARK: - PresentationRequestReviewState

enum PresentationRequestReviewState: Equatable {
  case loading
  case result(Result)
  case processing(Processing)

  struct Result: Equatable, Changeable {
    var credential: VerifiableCredentialViewModel
    let verifierDisplay: VerifierDisplay
    let claimBadges: [ClaimBadgeViewModel]
    let clusters: [CredentialClaimCluster]
  }

  struct Processing: Equatable, Changeable {
    var credential: VerifiableCredentialViewModel
    let verifierDisplay: VerifierDisplay
    var isMessagePresented: Bool
  }
}

#if DEBUG
extension PresentationRequestReviewState {
  struct Mock {
    static var result: PresentationRequestReviewState {
      let info = TrustInformation(identity: .untrusted, vcSchema: .untrusted)
      let display = VerifierDisplay(name: "Test", logo: nil, trustInformation: info)
      let credential = VerifiableCredentialViewModel(credential: .Mock.sample)
      let badges = [ClaimBadgeViewModel(name: "key1", isSensitive: true), ClaimBadgeViewModel(name: "Default claim display", isSensitive: false)]
      let viewState = PresentationRequestReviewState.Result(credential: credential, verifierDisplay: display, claimBadges: badges, clusters: CredentialClaimCluster.Mock.arrayWithDisplay)
      return .result(viewState)
    }

    static var processing: PresentationRequestReviewState {
      let info = TrustInformation(identity: .untrusted, vcSchema: .untrusted)
      let display = VerifierDisplay(name: "Test", logo: nil, trustInformation: info)
      let credential = VerifiableCredentialViewModel(credential: .Mock.sample)
      let viewState = PresentationRequestReviewState.Processing(credential: credential, verifierDisplay: display, isMessagePresented: true)
      return .processing(viewState)
    }
  }
}
#endif
