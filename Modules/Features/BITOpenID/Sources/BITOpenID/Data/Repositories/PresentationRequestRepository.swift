import BITJWT
import BITNetworking
import Factory
import Foundation
import Moya

// MARK: - PresentationRepository

struct PresentationRequestRepository: PresentationRequestRepositoryProtocol {

  // MARK: Internal

  func fetch(from url: URL) async throws -> PresentationRequest {
    do {
      let data = try await networkService.request(PresentationEndpoint.requestObject(url: url)).data
      guard let jws = try? jwsDecoder.decode(JWTRequestObjectPayload.self, from: data) else {
        let object = try decoder.decode(RequestObject.self, from: data)
        return .plain(object)
      }
      return .jwt(jws)
    } catch let error as NetworkError where error.status == .gone {
      throw FetchPresentationRequestError.expired
    } catch let error as NetworkError where error.status == .notFound {
      throw FetchPresentationRequestError.notFound
    }
  }

  func submit(from url: URL, presentationRequestBody: PresentationRequestBody) async throws {
    do {
      try await networkService.request(PresentationEndpoint.submission(url: url, presentationBody: presentationRequestBody))
    } catch {
      try handleError(error)
    }
  }

  func decline(url: URL, with error: PresentationErrorRequestBody.ErrorType) async throws {
    let presentationErrorRequestBody = PresentationErrorRequestBody(error: error)
    try await networkService.request(PresentationEndpoint.errorSubmission(url: url, presentationErrorBody: presentationErrorRequestBody))
  }

  // MARK: Private

  @Injected(\NetworkContainer.service) private var networkService: NetworkService
  @Injected(\NetworkContainer.decoder) private var decoder: JSONDecoder
  @Injected(\.jwsDecoder) private var jwsDecoder: JWSDecoderProtocol

  private func handleError(_ error: Error) throws {
    guard let err = error as? NetworkError else { throw error }
    switch err.status {
    case .internalServerError,
         .unprocessableEntity:
      throw SubmitPresentationError.presentationFailed
    case .badRequest:
      try handleBadRequest(err)
    case .invalidGrant:
      throw SubmitPresentationError.invalidCredential
    default: throw error
    }
  }

  private func handleBadRequest(_ error: NetworkError) throws {
    guard
      let errorData = error.response?.data,
      let errorBody = try? decoder.decode(PresentationErrorRequestBody.self, from: errorData)
    else { throw SubmitPresentationError.presentationFailed }

    switch errorBody.error {
    case .presentationProcessClosed:
      throw SubmitPresentationError.processClosed
    case .invalidRequest:
      throw SubmitPresentationError.presentationFailed
    case .invalidCredential:
      throw SubmitPresentationError.invalidCredential
    default: throw SubmitPresentationError.presentationFailed
    }
  }
}
