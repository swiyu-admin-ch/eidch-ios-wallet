import BITJWT
import BITNetworking
import Factory
import Foundation
import Moya

// MARK: - PresentationRequestRepository

struct PresentationRequestRepository: PresentationRequestRepositoryProtocol {

  // MARK: Internal

  func fetch(from url: URL) async throws -> PresentationRequest {
    do {
      let data = try await networkService.request(PresentationEndpoint.requestObject(url: url)).data
      guard let jws = try? jwsDecoder.decode(RequestObjectJWT.self, from: data) else {
        let object = try decoder.decode(RequestObject.self, from: data)
        object.raw = data
        return .plain(object)
      }
      return .jwt(jws)
    } catch let error as NetworkError where error.status == .gone {
      throw FetchPresentationRequestError.expired
    } catch let error as NetworkError where error.status == .notFound {
      throw FetchPresentationRequestError.notFound
    }
  }

  func submit(authorizationResponse: AuthorizationResponseBody, to url: URL) async throws {
    do {
      try await networkService.request(PresentationEndpoint.submission(url: url, authorizationResponse: authorizationResponse))
    } catch {
      throw parseAuthorizationResponseError(error)
    }
  }

  func decline(url: URL, with error: PresentationErrorRequestBody.Code) async throws {
    let presentationErrorRequestBody = PresentationErrorRequestBody(error: error)
    try await networkService.request(PresentationEndpoint.errorSubmission(url: url, presentationErrorBody: presentationErrorRequestBody))
  }

  // MARK: Private

  @Injected(\NetworkContainer.service) private var networkService: NetworkService
  @Injected(\NetworkContainer.decoder) private var decoder: JSONDecoder
  @Injected(\.jwsDecoder) private var jwsDecoder: JWSDecoderProtocol

  private func parseAuthorizationResponseError(_ error: Error) -> Error {
    guard let networkError = error as? NetworkError else { return error }
    switch networkError.status {
    case .badRequest:
      guard
        let data = networkError.response?.data,
        let responseError = try? decoder.decode(PresentationResponseError.self, from: data)
      else {
        return error
      }
      return PresentationRequestRepositoryError.presentationResponseError(responseError.error, responseError.errorDescription)
    case .invalidGrant:
      return PresentationRequestRepositoryError.invalidGrant
    default: return networkError
    }
  }
}

// MARK: - PresentationRequestRepositoryError

public enum PresentationRequestRepositoryError: Error, Equatable {
  case presentationResponseError(String?, String?)
  case invalidGrant
}
