import BITCredentialShared
import BITOpenID
import Spyable

// MARK: - SubmitPresentationEvent

public enum SubmitPresentationEvent: Equatable {
  case progress(Double?)
  case success(PresentationResponse?)
}

// MARK: - SubmitPresentationUseCaseProtocol

@Spyable
public protocol SubmitPresentationUseCaseProtocol {
  func execute(context: PresentationRequestContext) -> AsyncThrowingStream<SubmitPresentationEvent, Error>
}
