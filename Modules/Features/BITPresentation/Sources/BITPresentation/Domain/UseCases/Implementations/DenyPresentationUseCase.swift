import BITOpenID
import Factory
import Foundation

struct DenyPresentationUseCase: DenyPresentationUseCaseProtocol {

  func execute(requestObject: RequestObject, error: PresentationErrorRequestBody.ErrorType) async throws {
    guard let url = URL(string: requestObject.responseUri) else {
      throw SubmitPresentationError.wrongSubmissionUrl
    }

    let presentationErrorRequestBody = PresentationErrorRequestBody(error: error)
    try await repository.submitPresentation(from: url, presentationErrorRequestBody: presentationErrorRequestBody)
  }

  @Injected(\.presentationRepository) private var repository: PresentationRepositoryProtocol
}
