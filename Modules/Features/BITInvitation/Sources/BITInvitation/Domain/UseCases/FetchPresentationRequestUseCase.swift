import BITCredential
import BITJWT
import BITOpenID
import BITPresentation
import Factory
import Foundation
import Spyable

// MARK: - FetchPresentationRequestUseCaseProtocol

@Spyable
protocol FetchPresentationRequestUseCaseProtocol {
  func execute(url: URL) async throws -> PresentationRequestContext
}

// MARK: - FetchPresentationRequestUseCase

struct FetchPresentationRequestUseCase: FetchPresentationRequestUseCaseProtocol {

  // MARK: Internal

  func execute(url: URL) async throws -> PresentationRequestContext {
    let request = try await fetchRequest(from: url)
    let credentialsRequests = try await getCompatibleCredentialsUseCase.execute(using: request.requestObject)
    return try await createContext(request: request, credentialsRequests: credentialsRequests)
  }

  // MARK: Private

  @Injected(\.presentationRequestService) private var presentationRequestService
  @Injected(\.getCompatibleCredentialsUseCase) private var getCompatibleCredentialsUseCase
  @Injected(\.trustStatementService) private var trustStatementService

  private func fetchRequest(from url: URL) async throws -> PresentationRequest {
    do {
      return try await presentationRequestService.fetch(from: url)
    } catch let error as FetchPresentationRequestError {
      switch error {
      case .invalidRequestUrl:
        throw FetchPresentationRequestUseCaseError.invalidUrl
      case .expired:
        throw FetchPresentationRequestUseCaseError.expiredRequest
      case .invalid(let request):
        try? await presentationRequestService.decline(for: request.requestObject, with: .invalidRequest) // ignore errors as it's fire-and-forget
        throw FetchPresentationRequestUseCaseError.invalidRequest
      case .notFound:
        throw FetchPresentationRequestUseCaseError.invalidRequest
      }
    } catch is RequestObjectError, is DecodingError, is JWSDecoderError {
      throw FetchPresentationRequestUseCaseError.invalidRequest
    }
  }

  private func createContext(request: PresentationRequest, credentialsRequests: [InputDescriptorID: [CompatibleCredential]]) async throws -> PresentationRequestContext {
    let context = PresentationRequestContext(requestObject: request.requestObject, requests: credentialsRequests)
    guard context.hasCompatibleCredentials else { throw FetchPresentationRequestUseCaseError.invalidRequest }
    if case .jwt(let jws) = request {
      context.trustStatement = try? await trustStatementService.fetch(for: jws.payload.issuer)
    }
    return context
  }
}

// MARK: - FetchPresentationRequestUseCaseError

enum FetchPresentationRequestUseCaseError: Error {
  case invalidUrl
  case invalidRequest
  case expiredRequest
}
