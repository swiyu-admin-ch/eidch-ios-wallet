import BITEIDRequestShared
import Foundation
import Spyable
import SwiftUI

// MARK: - RequestCaseViewStateDelegate

@Spyable
public protocol RequestCaseViewStateDelegate: AnyObject {
  func didDeleteRequestCase()
  func didStartAutoVerification(caseId: String)
  func didUpdateRequestCaseState()
  func didTapObtainConsent(caseId: String)
  func didOpenExternalLink(url: URL)
}

extension RequestCaseViewStateDelegate {
  func didDeleteRequestCase() { }
  func didStartAutoVerification(caseId: String) { }
  func didUpdateRequestCaseState() { }
  func didTapObtainConsent(caseId: String) { }
  func didOpenExternalLink(url: URL) { }
}

// MARK: - RequestCaseViewStateError

enum RequestCaseViewStateError: Error {
  case invalidState
  case unsupportedState
}

// MARK: - RequestCaseViewState

public enum RequestCaseViewState: Identifiable {
  case inQueue(InQueueStateViewModel)
  case readyForOnlineSession(ReadyForOnlineSessionStateViewModel)
  case expired(ExpiredStateViewModel)
  case unknown(UnknownStateViewModel)
  case agentReview(AgentReviewStateViewModel)
  case declined(DeclinedStateViewModel)

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
    case .declined:
      self = try .declined(DeclinedStateViewModel(requestCase: requestCase, delegate: delegate))
    case .cancelled,
         .inTargetWalletPairing,
         .unknown:
      throw RequestCaseViewStateError.unsupportedState
    }
  }

  // MARK: Public

  public var id: String {
    switch self {
    case .agentReview(let viewModel as RequestCaseStateBaseViewModel),
         .declined(let viewModel as RequestCaseStateBaseViewModel),
         .expired(let viewModel as RequestCaseStateBaseViewModel),
         .inQueue(let viewModel as RequestCaseStateBaseViewModel),
         .readyForOnlineSession(let viewModel as RequestCaseStateBaseViewModel),
         .unknown(let viewModel as RequestCaseStateBaseViewModel):
      viewModel.id
    }
  }

  public var requestCaseId: String {
    switch self {
    case .agentReview(let viewModel as RequestCaseStateBaseViewModel),
         .declined(let viewModel as RequestCaseStateBaseViewModel),
         .expired(let viewModel as RequestCaseStateBaseViewModel),
         .inQueue(let viewModel as RequestCaseStateBaseViewModel),
         .readyForOnlineSession(let viewModel as RequestCaseStateBaseViewModel),
         .unknown(let viewModel as RequestCaseStateBaseViewModel):
      viewModel.requestCaseId
    }
  }

  public var isLegalRepresentantConsentVerified: Bool {
    switch self {
    case .agentReview(let viewModel as RequestCaseStateBaseViewModel),
         .declined(let viewModel as RequestCaseStateBaseViewModel),
         .expired(let viewModel as RequestCaseStateBaseViewModel),
         .inQueue(let viewModel as RequestCaseStateBaseViewModel),
         .readyForOnlineSession(let viewModel as RequestCaseStateBaseViewModel),
         .unknown(let viewModel as RequestCaseStateBaseViewModel):
      viewModel.isLegalRepresentantConsentVerified
    }
  }
}

// MARK: Equatable

extension RequestCaseViewState: Equatable {
  public static func == (lhs: RequestCaseViewState, rhs: RequestCaseViewState) -> Bool {
    lhs.requestCaseId == rhs.requestCaseId &&
      lhs.isLegalRepresentantConsentVerified == rhs.isLegalRepresentantConsentVerified
  }
}

extension RequestCaseViewState {

  @ViewBuilder
  func view() -> some View {
    switch self {
    case .agentReview(let viewModel):
      AgentReviewCell(viewModel: viewModel)
    case .inQueue(let viewModel):
      InQueueCell(viewModel: viewModel)
    case .readyForOnlineSession(let viewModel):
      ReadyForAVCell(viewModel: viewModel)
    case .expired(let viewModel):
      ExpiredCell(viewModel: viewModel)
    case .declined(let viewModel):
      DeclinedCell(viewModel: viewModel)
    case .unknown(let viewModel):
      UnknownCell(viewModel: viewModel)
    }
  }
}
