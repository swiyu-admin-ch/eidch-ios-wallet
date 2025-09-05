import BITJWT
import Factory
import Foundation
import Spyable

// MARK: - PresentationRequestServiceProtocol

@Spyable
public protocol PresentationRequestServiceProtocol {
  func fetch(from url: URL) async throws -> PresentationRequest
  func decline(for requestObject: RequestObject, with error: PresentationErrorRequestBody.ErrorType) async throws
}

// MARK: - PresentationRequestService

struct PresentationRequestService: PresentationRequestServiceProtocol {

  // MARK: Internal

  func fetch(from url: URL) async throws -> PresentationRequest {
    let requestURL = try urlParser.parse(url)
    let request = try await repository.fetch(from: requestURL.url)
    guard
      validateClientId(url: requestURL, requestObject: request.requestObject),
      await validateRequest(request)
    else {
      throw FetchPresentationRequestError.invalid(request: request)
    }
    return request
  }

  func decline(for requestObject: RequestObject, with error: PresentationErrorRequestBody.ErrorType) async throws {
    try await repository.decline(url: requestObject.responseUri, with: error)
  }

  // MARK: Private

  @Injected(\.presentationRequestUrlParser) private var urlParser
  @Injected(\.presentationRequestRepository) private var repository
  @Injected(\.jwsValidator) private var jwsValidator
  @Injected(\.requestObjectValidator) private var requestObjectValidator

  private func validateClientId(url: PresentationRequestUrl, requestObject: RequestObject) -> Bool {
    if case .openID4VP(_, let clientId) = url {
      guard clientId == requestObject.clientId else {
        return false
      }
    }
    return true
  }

  private func validateRequest(_ presentationRequest: PresentationRequest) async -> Bool {
    if case .jwt(let jwtRequestObject) = presentationRequest {
      guard await validateJWS(of: jwtRequestObject) else {
        return false
      }
    }
    return requestObjectValidator.validate(presentationRequest.requestObject)
  }

  private func validateJWS(of jwtRequestObject: JWTRequestObject) async -> Bool {
    guard jwtRequestObject.header.algorithm == JWTAlgorithm.ES256 else { return false }
    return (try? await jwsValidator.validate(jwtRequestObject, issuerDid: jwtRequestObject.payload.clientId)) ?? false
  }
}
