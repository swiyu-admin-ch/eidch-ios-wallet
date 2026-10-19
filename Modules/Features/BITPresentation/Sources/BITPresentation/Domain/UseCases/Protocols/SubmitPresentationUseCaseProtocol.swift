import BITCredentialShared
import BITOpenID
import Spyable

// MARK: - SubmitPresentationEvent

public enum SubmitPresentationEvent: Equatable, Sendable {
  case progress(Double?)
  case success(PresentationResponse?)
}

// MARK: - SubmitPresentationUseCaseProtocol

@Spyable
public protocol SubmitPresentationUseCaseProtocol: Sendable {
  func execute(context: PresentationRequestContext) -> AsyncThrowingStream<SubmitPresentationEvent, Error>
}
