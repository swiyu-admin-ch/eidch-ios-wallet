import BITCredential
import BITJWT
import BITOpenID
import BITPresentation
import BITSdJWT
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
    let compatibleCredentials = try await getCompatibleCredentialsUseCase.execute(using: request.requestObject)
    return try await createContext(request: request, compatibleCredentials: compatibleCredentials)
  }

  // MARK: Private

  @Injected(\.presentationRequestService) private var presentationRequestService
  @Injected(\.getCompatibleCredentialsUseCase) private var getCompatibleCredentialsUseCase
  @Injected(\.trustInformationService) private var trustInformationService

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
        try? await presentationRequestService.decline(url: request.requestObject.responseUri, with: .invalidRequest) // ignore errors as it's fire-and-forget
        throw FetchPresentationRequestUseCaseError.invalidRequest
      case .notFound:
        throw FetchPresentationRequestUseCaseError.invalidRequest
      }
    } catch is RequestObjectError, is DecodingError, is JWSDecoderError {
      throw FetchPresentationRequestUseCaseError.invalidRequest
    }
  }

  private func createContext(request: PresentationRequest, compatibleCredentials: [CompatibleCredential]) async throws -> PresentationRequestContext {
    let context = PresentationRequestContext(presentationRequest: request, compatibleCredentials: compatibleCredentials)
    if case .jwt(let jws) = request {
      context.trustInformation = await trustInformationService.fetch(for: jws.payload.clientId, type: .verification, vcSchemaId: jws.payload.requestedVcSchemaId)
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

extension RequestObjectJWT {

  // MARK: Fileprivate

  fileprivate var requestedVcSchemaId: String? {
    guard let inputDescriptors = presentationDefinition?.inputDescriptors else { return nil }
    return inputDescriptors.compactMap { descriptor in
      let vcSchemaIdField = descriptor.constraints.fields.first { field in
        field.path.contains { vcSchemaIdPaths.contains($0) }
      }
      return vcSchemaIdField?.filter?.const
    }.first // only support first input descriptor for now
  }

  // MARK: Private

  private var vcSchemaIdPaths: [String] {
    [VcSdJwt.vctPath]
  }

}
