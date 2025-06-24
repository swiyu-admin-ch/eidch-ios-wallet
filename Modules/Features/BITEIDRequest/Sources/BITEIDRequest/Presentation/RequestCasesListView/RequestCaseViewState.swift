import Foundation
import Spyable
import SwiftUI

// MARK: - RequestCaseViewStateDelegate

@Spyable
public protocol RequestCaseViewStateDelegate: AnyObject {
  func didDeleteRequestCase()
  func didStartAutoVerification()
  func didUpdateRequestCaseState()
  func didTapObtainConsent(caseId: String)
}

extension RequestCaseViewStateDelegate {
  func didDeleteRequestCase() { }
  func didStartAutoVerification() { }
  func didUpdateRequestCaseState() { }
  func didTapObtainConsent(caseId: String) { }
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
    default:
      throw RequestCaseViewStateError.unsupportedState
    }
  }

  // MARK: Public

  public var id: String {
    switch self {
    case .expired(let viewModel as RequestCaseStateBaseViewModel),
         .inQueue(let viewModel as RequestCaseStateBaseViewModel),
         .readyForOnlineSession(let viewModel as RequestCaseStateBaseViewModel),
         .unknown(let viewModel as RequestCaseStateBaseViewModel):
      viewModel.requestCaseId
    }
  }

  public var isLegalRepresentantConsentVerified: Bool {
    switch self {
    case .expired(let viewModel as RequestCaseStateBaseViewModel),
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
    lhs.id == rhs.id
  }
}

extension RequestCaseViewState {

  @ViewBuilder
  func view() -> some View {
    switch self {
    case .inQueue(let viewModel):
      InQueueCell(viewModel: viewModel)
    case .readyForOnlineSession(let viewModel):
      ReadyForAVCell(viewModel: viewModel)
    case .expired(let viewModel):
      ExpiredCell(viewModel: viewModel)
    case .unknown(let viewModel):
      UnknownCell(viewModel: viewModel)
    }
  }
}
