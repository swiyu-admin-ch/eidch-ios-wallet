import BITJWT
import Factory
import Foundation
import Spyable

// MARK: - PresentationRequestServiceProtocol

@Spyable
public protocol PresentationRequestServiceProtocol {
  func fetch(from url: URL) async throws -> RequestObjectJWS
  func decline(url: URL, with error: PresentationErrorRequestBody.Code) async throws
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

  func decline(url: URL, with error: PresentationErrorRequestBody.Code) async throws {
    try await repository.decline(url: url, with: error)
  }

  // MARK: Private

  @Injected(\.presentationRequestUrlParser) private var urlParser
  @Injected(\.presentationRequestRepository) private var repository
  @Injected(\.requestObjectValidator) private var requestObjectValidator

  private func validate(_ jws: RequestObjectJWS, for url: PresentationRequestUrl) async throws {
    do {
      try validate(jws.payload, for: url)
      try await requestObjectValidator.validate(jws)
    } catch {
      throw mapValidationError(error, for: jws.payload)
    }
  }

  private func validate(_ requestObject: RequestObject, for url: PresentationRequestUrl) throws {
    if case .openID4VP(_, let clientId) = url {
      guard clientId.normalizedDid() == requestObject.clientId.normalizedDid() else {
        throw PresentationRequestValidationError.invalidClientId
      }
    }
  }

  private func mapError(_ error: Error) -> PresentationRequestServiceError {
    switch error {
    case let error as PresentationRequestServiceError:
      error
    case PresentationRequestUrlParserError.invalidRequestUrl:
      .invalidRequestUrl
    case let error as PresentationRequestRepositoryError:
      mapRepositoryError(error) ?? .invalid(responseURL: nil, responseError: .invalidRequest)
    default:
      .invalid(responseURL: nil, responseError: .invalidRequest)
    }
  }

  private func mapRepositoryError(_ error: PresentationRequestRepositoryError) -> PresentationRequestServiceError? {
    switch error {
    case .presentationRequestExpired: .expired
    case .presentationRequestNotFound: .presentationRequestNotFound
    }
  }

  private func mapValidationError(_ error: Error, for requestObject: RequestObject) -> PresentationRequestServiceError {
    switch error {
    case RequestObjectValidationError.transactionDataNotSupported:
      .transactionDataNotSupported(responseURL: requestObject.responseUri, responseError: .invalidRequest)
    default:
      .invalid(responseURL: requestObject.responseUri, responseError: .invalidRequest)
    }
  }
}

// MARK: - PresentationRequestServiceError

public enum PresentationRequestServiceError: Error, Equatable {
  case invalidRequestUrl
  case expired
  case presentationRequestNotFound
  case invalid(responseURL: URL?, responseError: PresentationErrorRequestBody.Code)
  case transactionDataNotSupported(responseURL: URL?, responseError: PresentationErrorRequestBody.Code)
}

// MARK: - PresentationRequestValidationError

enum PresentationRequestValidationError: Error {
  case invalidClientId
}
