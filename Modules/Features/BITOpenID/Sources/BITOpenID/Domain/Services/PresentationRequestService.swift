import BITJWT
import Factory
import Foundation
import Spyable

// MARK: - PresentationRequestServiceProtocol

@Spyable
public protocol PresentationRequestServiceProtocol {
  func fetch(from url: URL) async throws -> RequestObjectJWS
  func decline(url: URL, with error: PresentationErrorRequestBody.Code) async throws -> PresentationResponse?
}

// MARK: - PresentationRequestService

struct PresentationRequestService: PresentationRequestServiceProtocol {

  // MARK: Internal

  func fetch(from url: URL) async throws -> RequestObjectJWS {
    do {
      let requestURL = try urlParser.parse(url)
      let jws = try await repository.fetch(from: requestURL.url)

      try await validate(jws, for: requestURL)

      return jws
    } catch {
      throw mapError(error)
    }
  }

  func decline(url: URL, with error: PresentationErrorRequestBody.Code) async throws -> PresentationResponse? {
    try await repository.decline(url: url, with: error)
  }

  // MARK: Private

  @Injected(\.presentationRequestUrlParser) private var urlParser
  @Injected(\.presentationRequestRepository) private var repository
  @Injected(\.requestObjectValidator) private var requestObjectValidator

  private func validate(_ jws: RequestObjectJWS, for url: PresentationRequestUrl) async throws {
    do {
      try validate(jws.payload, for: url)
      try await requestObjectValidator.validate(jws, transport: .network)
    } catch {
      throw mapValidationError(error, for: jws.payload)
    }
  }

  private func validate(_ requestObject: RequestObject, for url: PresentationRequestUrl) throws {
    if case .openID4VP(_, let clientId) = url {
      let urlIdentifier = try ClientIdentifier(rawClientId: clientId)
      guard urlIdentifier == requestObject.clientIdentifier else {
        throw PresentationRequestValidationError.invalidClientId
      }
    }
  }

  private func mapError(_ error: Error) -> PresentationRequestError {
    switch error {
    case let error as PresentationRequestError:
      error
    case PresentationRequestUrlParserError.invalidRequestUrl:
      .invalidRequestUrl
    case let error as PresentationRequestRepositoryError:
      mapRepositoryError(error) ?? .invalid(responseURL: nil, responseError: .invalidRequest)
    default:
      .invalid(responseURL: nil, responseError: .invalidRequest)
    }
  }

  private func mapRepositoryError(_ error: PresentationRequestRepositoryError) -> PresentationRequestError? {
    switch error {
    case .presentationRequestExpired: .expired
    case .presentationRequestNotFound: .presentationRequestNotFound
    }
  }

  private func mapValidationError(_ error: Error, for requestObject: RequestObject) -> PresentationRequestError {
    PresentationRequestError(validationError: error, responseURL: requestObject.responseUri)
  }
}

// MARK: - PresentationRequestValidationError

enum PresentationRequestValidationError: Error {
  case invalidClientId
}
