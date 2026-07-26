import BITCredential
import BITJWT
import BITOpenID
import BITPresentation
import BITSwiyuSharedKMP
import Factory
import Foundation
import Spyable

// MARK: - FetchPresentationRequestUseCaseProtocol

@Spyable
public protocol FetchPresentationRequestUseCaseProtocol {
  func execute(url: URL) async throws -> PresentationRequestContext
}

// MARK: - FetchPresentationRequestUseCase

public struct FetchPresentationRequestUseCase: FetchPresentationRequestUseCaseProtocol {

  // MARK: Public

  public func execute(url: URL) async throws -> PresentationRequestContext {
    let request = try await fetchRequest(from: url)
    let compatibleCredentials = try await getCompatibleCredentialsUseCase.execute(using: request.payload)
    return try await createContext(requestObjectJWS: request, compatibleCredentials: compatibleCredentials)
  }

  // MARK: Private

  @Injected(\.presentationRequestService) private var presentationRequestService
  @Injected(\.getCompatibleCredentialsUseCase) private var getCompatibleCredentialsUseCase
  @Injected(\.trustInformationService) private var trustInformationService

  private func fetchRequest(from url: URL) async throws -> RequestObjectJWS {
    do {
      return try await presentationRequestService.fetch(from: url)
    } catch let error as PresentationRequestServiceError {
      switch error {
      case .invalidRequestUrl:
        throw FetchPresentationRequestUseCaseError.invalidUrl
      case .expired:
        throw FetchPresentationRequestUseCaseError.expired
      case .invalid(let responseUri, let responseError):
        if let responseUri {
          try? await presentationRequestService.decline(url: responseUri, with: responseError)
        }
        throw FetchPresentationRequestUseCaseError.invalidRequest(responseError.rawValue)
      case .transactionDataNotSupported(let responseUri, let responseError):
        if let responseUri {
          try? await presentationRequestService.decline(url: responseUri, with: responseError)
        }
        throw FetchPresentationRequestUseCaseError.transactionDataNotSupported(responseError.rawValue)
      case .presentationRequestNotFound:
        throw FetchPresentationRequestUseCaseError.notFound
      }
    }
  }

  private func createContext(requestObjectJWS: RequestObjectJWS, compatibleCredentials: [CompatibleCredential]) async throws -> PresentationRequestContext {
    let context = PresentationRequestContext(requestObjectJWS: requestObjectJWS, compatibleCredentials: compatibleCredentials)
    context.trustInformation = await trustInformationService.fetch(for: requestObjectJWS.payload.clientId.normalizedDid(), type: .verification, vcSchemaId: requestObjectJWS.payload.requestedVcSchemaId)
    return context
  }
}

// MARK: - FetchPresentationRequestUseCaseError

enum FetchPresentationRequestUseCaseError: Error, Equatable {
  case invalidUrl
  case invalidRequest(String)
  case transactionDataNotSupported(String)
  case expired
  case notFound
}

extension RequestObject {

  fileprivate var requestedVcSchemaId: String? {
    guard let credentials = dcqlQuery?.credentials else { return nil }
    return credentials.compactMap { credential in
      guard let meta = credential.meta as? Heidi_dcqlMeta.SdjwtVc else { return nil }
      return meta.vctValues.first
    }.first
  }

}
