import Foundation
import Spyable

// MARK: - RequestCaseViewStateDelegate

@Spyable
public protocol RequestCaseViewStateDelegate: AnyObject {
  func didDeleteRequestCase()
  func didStartAutoVerification()
}

extension RequestCaseViewStateDelegate {
  func didDeleteRequestCase() { }

  func didStartAutoVerification() { }
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

  // MARK: Lifecycle

  public init (_ requestCase: EIDRequestCase, delegate: RequestCaseViewStateDelegate? = nil) throws {
    switch requestCase.state?.state {
    case .inQueue:
      self = try .inQueue(InQueueStateViewModel(requestCase: requestCase))
    case .readyForOnlineSession:
      self = try .readyForOnlineSession(ReadyForOnlineSessionStateViewModel(requestCase: requestCase, delegate: delegate))
    case .expired:
      self = try .expired(ExpiredStateViewModel(requestCase: requestCase, delegate: delegate))
    default:
      throw RequestCaseViewStateError.unsupportedState
    }
  }

  // MARK: Public

  public var id: String {
    switch self {
    case .expired(let viewModel as RequestCaseStateBaseViewModel),
         .inQueue(let viewModel as RequestCaseStateBaseViewModel),
         .readyForOnlineSession(let viewModel as RequestCaseStateBaseViewModel):
      viewModel.requestCaseId
    }
  }
}

// MARK: Equatable

extension RequestCaseViewState: Equatable {
  public static func == (lhs: RequestCaseViewState, rhs: RequestCaseViewState) -> Bool {
    lhs.id == rhs.id
  }
}
