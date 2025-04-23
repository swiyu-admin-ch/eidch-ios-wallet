import BITOpenID
import Spyable

@Spyable
public protocol DenyPresentationUseCaseProtocol {
  func execute(requestObject: RequestObject, error: PresentationErrorRequestBody.ErrorType) async throws
}
