import BITEIDRequestShared
import Foundation
import Spyable

// MARK: - RequestCaseViewStateDelegate

@Spyable
public protocol RequestCaseViewStateDelegate: AnyObject {
  func didDeleteRequestCase()
  func didStartAutoVerification(caseId: String)
  func didUpdateRequestCaseState()
  func didTapObtainConsent(caseId: String)
  func didOpenExternalLink(url: URL)
  func didTapWalletPairing(caseId: String)
  func didTapIdentityCheck(caseId: String)
}

extension RequestCaseViewStateDelegate {
  func didDeleteRequestCase() { }
  func didStartAutoVerification(caseId: String) { }
  func didUpdateRequestCaseState() { }
  func didTapObtainConsent(caseId: String) { }
  func didOpenExternalLink(url: URL) { }
  func didTapWalletPairing(caseId: String) { }
  func didTapIdentityCheck(caseId: String) { }
}

// MARK: - RequestCaseViewStateError

enum RequestCaseViewStateError: Error {
  case invalidState
  case unsupportedState
}

// MARK: - RequestCaseViewState

public enum RequestCaseViewState: Identifiable, Hashable {
  case inQueue(InQueueStateViewModel)
  case readyForOnlineSession(ReadyForOnlineSessionStateViewModel)
  case expired(ExpiredStateViewModel)
  case unknown(UnknownStateViewModel)
  case agentReview(AgentReviewStateViewModel)
  case readyForFinalEntitlementCheck(ReadyForFinalEntitlementCheckStateViewModel)
  case refused(RefusedStateViewModel)
  case walletPairing(WalletPairingStateViewModel)
  case autoVerification(AutoVerificationStateViewModel)
  case closed(ClosedStateViewModel)
  case issuing(IssuingStateViewModel)
  case cancelled(CancelledStateViewModel)

  // MARK: Lifecycle

  public init (_ requestCase: EIDRequestCase, delegate: RequestCaseViewStateDelegate? = nil) throws {
    switch requestCase.state?.state {
    case .inQueue:
      self = try .inQueue(InQueueStateViewModel(requestCase: requestCase, delegate: delegate))
    case .readyForOnlineSession:
      self = try .readyForOnlineSession(ReadyForOnlineSessionStateViewModel(requestCase: requestCase, delegate: delegate))
    case .expired:
      self = try .expired(ExpiredStateViewModel(requestCase: requestCase, delegate: delegate))
    case .none:
      self = try .unknown(UnknownStateViewModel(requestCase: requestCase, delegate: delegate))
    case .agentReview:
      self = try .agentReview(AgentReviewStateViewModel(requestCase: requestCase))
    case .readyForFinalEntitlementCheck:
      self = try .readyForFinalEntitlementCheck(ReadyForFinalEntitlementCheckStateViewModel(requestCase: requestCase))
    case .refused:
      self = try .refused(RefusedStateViewModel(requestCase: requestCase, delegate: delegate))
    case .inTargetWalletPairing:
      self = try .walletPairing(WalletPairingStateViewModel(requestCase: requestCase, delegate: delegate))
    case .autoVerification:
      self = try .autoVerification(AutoVerificationStateViewModel(requestCase: requestCase, delegate: delegate))
    case .closed:
      self = try .closed(ClosedStateViewModel(requestCase: requestCase, delegate: delegate))
    case .issuing:
      self = try .issuing(IssuingStateViewModel(requestCase: requestCase))
    case .cancelled:
      self = try .cancelled(CancelledStateViewModel(requestCase: requestCase, delegate: delegate))
    case .unknown:
      throw RequestCaseViewStateError.unsupportedState
    }
  }

  // MARK: Public

  public var id: String {
    switch self {
    case .agentReview(let viewModel as RequestCaseStateBaseViewModel),
         .autoVerification(let viewModel as RequestCaseStateBaseViewModel),
         .cancelled(let viewModel as RequestCaseStateBaseViewModel),
         .closed(let viewModel as RequestCaseStateBaseViewModel),
         .expired(let viewModel as RequestCaseStateBaseViewModel),
         .inQueue(let viewModel as RequestCaseStateBaseViewModel),
         .issuing(let viewModel as RequestCaseStateBaseViewModel),
         .readyForFinalEntitlementCheck(let viewModel as RequestCaseStateBaseViewModel),
         .readyForOnlineSession(let viewModel as RequestCaseStateBaseViewModel),
         .refused(let viewModel as RequestCaseStateBaseViewModel),
         .unknown(let viewModel as RequestCaseStateBaseViewModel),
         .walletPairing(let viewModel as RequestCaseStateBaseViewModel):
      viewModel.id
    }
  }

  public var requestCaseId: String {
    switch self {
    case .agentReview(let viewModel as RequestCaseStateBaseViewModel),
         .autoVerification(let viewModel as RequestCaseStateBaseViewModel),
         .cancelled(let viewModel as RequestCaseStateBaseViewModel),
         .closed(let viewModel as RequestCaseStateBaseViewModel),
         .expired(let viewModel as RequestCaseStateBaseViewModel),
         .inQueue(let viewModel as RequestCaseStateBaseViewModel),
         .issuing(let viewModel as RequestCaseStateBaseViewModel),
         .readyForFinalEntitlementCheck(let viewModel as RequestCaseStateBaseViewModel),
         .readyForOnlineSession(let viewModel as RequestCaseStateBaseViewModel),
         .refused(let viewModel as RequestCaseStateBaseViewModel),
         .unknown(let viewModel as RequestCaseStateBaseViewModel),
         .walletPairing(let viewModel as RequestCaseStateBaseViewModel):
      viewModel.id
    }
  }

  public var isLegalRepresentantConsentVerified: Bool {
    switch self {
    case .agentReview(let viewModel as RequestCaseStateBaseViewModel),
         .autoVerification(let viewModel as RequestCaseStateBaseViewModel),
         .cancelled(let viewModel as RequestCaseStateBaseViewModel),
         .closed(let viewModel as RequestCaseStateBaseViewModel),
         .expired(let viewModel as RequestCaseStateBaseViewModel),
         .inQueue(let viewModel as RequestCaseStateBaseViewModel),
         .issuing(let viewModel as RequestCaseStateBaseViewModel),
         .readyForFinalEntitlementCheck(let viewModel as RequestCaseStateBaseViewModel),
         .readyForOnlineSession(let viewModel as RequestCaseStateBaseViewModel),
         .refused(let viewModel as RequestCaseStateBaseViewModel),
         .unknown(let viewModel as RequestCaseStateBaseViewModel),
         .walletPairing(let viewModel as RequestCaseStateBaseViewModel):
      viewModel.isLegalRepresentantConsentVerified
    }
  }
}
