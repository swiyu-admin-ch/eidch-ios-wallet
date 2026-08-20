import BITCredential
import BITNonCompliance
import BITOpenID
import BITPresentation
import Factory
import Foundation
import Spyable

// MARK: - FetchPresentationRequestUseCaseProtocol

@Spyable
public protocol FetchPresentationRequestUseCaseProtocol {
  func callAsFunction(url: URL) async throws -> PresentationRequestContext
}

// MARK: - FetchPresentationRequestUseCase

struct FetchPresentationRequestUseCase: FetchPresentationRequestUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(url: URL) async throws -> PresentationRequestContext {
    let request = try await fetchRequest(from: url)
    try await validateActor(in: request.payload)
    let compatibleCredentials = try await getCompatibleCredentialsUseCase(using: request.payload)
    return await createContext(requestObjectJWS: request, compatibleCredentials: compatibleCredentials)
  }

  // MARK: Private

  @Injected(\.presentationRequestService) private var presentationRequestService
  @Injected(\.getCompatibleCredentialsUseCase) private var getCompatibleCredentialsUseCase
  @Injected(\.nonComplianceRepository) private var nonComplianceRepository: NonComplianceRepositoryProtocol
  @Injected(\.trustInformationService) private var trustInformationService
  @Injected(\.actorIdentityValidator) private var actorIdentityValidator

  private func fetchRequest(from url: URL) async throws -> RequestObjectJWS {
    do {
      return try await presentationRequestService.fetch(from: url)
    } catch let error as PresentationRequestError {
      switch error {
      case .invalidRequestUrl:
        throw FetchPresentationRequestUseCaseError.invalidUrl
      case .expired:
        throw FetchPresentationRequestUseCaseError.expired
      case .invalid(let responseUri, let responseError):
        let presentationResponse = try await decline(url: responseUri, with: responseError)
        throw FetchPresentationRequestUseCaseError.invalidRequest(
          responseError.rawValue,
          presentationResponse: presentationResponse)
      case .transactionDataNotSupported(let responseUri, let responseError):
        let presentationResponse = try await decline(url: responseUri, with: responseError)
        throw FetchPresentationRequestUseCaseError.transactionDataNotSupported(
          responseError.rawValue,
          presentationResponse: presentationResponse)
      case .presentationRequestNotFound:
        throw FetchPresentationRequestUseCaseError.notFound
      }
    } catch {
      throw FetchPresentationRequestUseCaseError.invalidRequest(error.localizedDescription)
    }
  }

  private func createContext(requestObjectJWS: RequestObjectJWS, compatibleCredentials: [CompatibleCredential]) async -> PresentationRequestContext {
    let context = PresentationRequestContext(requestObjectJWS: requestObjectJWS, compatibleCredentials: compatibleCredentials)
    #warning("TODO: remove trustInformation & legacyVerifierNames when Trust 2.0 is enforced (TP 2.0)")
    if requestObjectJWS.payload.identityTrustStatement != nil {
      context.trustInformation = TrustInformation(identity: .trusted, vcSchema: .notProtected)
    } else {
      context.trustInformation = await trustInformationService.fetch(
        for: requestObjectJWS.payload.clientIdentifier.clientId.normalizedDid(),
        type: .verification,
        vcSchemaId: nil)
    }
    context.actorCompliance = await fetchActorCompliance(for: requestObjectJWS.payload.clientIdentifier.clientId)
    if requestObjectJWS.payload.identityTrustStatement == nil {
      context.legacyVerifierNames = await trustInformationService.getEntityNames(for: requestObjectJWS.header.keyIdentifier)
    }
    return context
  }

  private func validateActor(in requestObject: RequestObject) async throws {
    do {
      try await actorIdentityValidator.validate(requestObject.identityTrustStatement, for: requestObject.clientIdentifier.clientId)
    } catch GovernanceError.unverifiedActor {
      let presentationResponse = try await decline(url: requestObject.responseUri, with: .accessDenied)
      throw FetchPresentationRequestUseCaseError.unverifiedActor(presentationResponse: presentationResponse)
    } catch GovernanceError.unknownRegistry {
      let presentationResponse = try await decline(url: requestObject.responseUri, with: .accessDenied)
      throw FetchPresentationRequestUseCaseError.unknownRegistry(presentationResponse: presentationResponse)
    }
  }

  private func decline(url: URL?, with error: PresentationErrorRequestBody.Code) async throws -> PresentationResponse? {
    guard let url else { return nil }
    do {
      return try await presentationRequestService.decline(url: url, with: error)
    } catch let error as PresentationResponseValidationError {
      throw error
    } catch {
      return nil
    }
  }

  private func fetchActorCompliance(for subjectDid: String) async -> ActorCompliance {
    (try? await nonComplianceRepository.fetchActorCompliance(for: subjectDid)) ?? .notCompliant(nil)
  }
}

// MARK: - FetchPresentationRequestUseCaseError

enum FetchPresentationRequestUseCaseError: Error, Equatable {
  case invalidUrl
  case invalidRequest(String, presentationResponse: PresentationResponse? = nil)
  case transactionDataNotSupported(String, presentationResponse: PresentationResponse? = nil)
  case unverifiedActor(presentationResponse: PresentationResponse? = nil)
  case unknownRegistry(presentationResponse: PresentationResponse? = nil)
  case expired
  case notFound

  var presentationResponse: PresentationResponse? {
    switch self {
    case .invalidRequest(_, let presentationResponse),
         .transactionDataNotSupported(_, let presentationResponse),
         .unknownRegistry(let presentationResponse),
         .unverifiedActor(let presentationResponse):
      presentationResponse
    default:
      nil
    }
  }
}
