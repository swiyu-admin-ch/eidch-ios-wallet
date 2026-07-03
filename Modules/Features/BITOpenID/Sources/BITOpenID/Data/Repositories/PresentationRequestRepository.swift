import BITJWT
import BITNetworking
import Factory
import Foundation
import Moya

// MARK: - PresentationRequestRepository

struct PresentationRequestRepository: PresentationRequestRepositoryProtocol {

  // MARK: Internal

  func fetch(from url: URL) async throws -> RequestObjectJWS {
    do {
      let data = try await networkService.request(PresentationEndpoint.requestObject(url: url)).data
      return try jwsDecoder.decode(RequestObjectJWT.self, from: data)
    } catch let error as NetworkError where error.status == .gone {
      throw PresentationRequestRepositoryError.presentationRequestExpired
    } catch let error as NetworkError where error.status == .notFound {
      throw PresentationRequestRepositoryError.presentationRequestNotFound
    }
  }

  func submit(authorizationResponse: AuthorizationResponseBody, to url: URL) async throws {
    try await networkService.request(PresentationEndpoint.submission(url: url, authorizationResponse: authorizationResponse))
  }

  func decline(url: URL, with error: PresentationErrorRequestBody.Code) async throws {
    let presentationErrorRequestBody = PresentationErrorRequestBody(error: error)
    try await networkService.request(PresentationEndpoint.errorSubmission(url: url, presentationErrorBody: presentationErrorRequestBody))
  }

  // MARK: Private

  @Injected(\NetworkContainer.service) private var networkService: NetworkService
  @Injected(\NetworkContainer.decoder) private var decoder: JSONDecoder
  @Injected(\.jwsDecoder) private var jwsDecoder: JWSDecoderProtocol
}

// MARK: - PresentationRequestRepositoryError

public enum PresentationRequestRepositoryError: Error, Equatable {
  case presentationRequestExpired
  case presentationRequestNotFound
}
