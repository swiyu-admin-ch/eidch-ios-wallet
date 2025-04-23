import BITCredential
import BITOpenID
import BITPresentation
import Factory
import Foundation
import Spyable

// MARK: - ProcessPresentationRequestUseCaseProtocol

@Spyable
protocol ProcessPresentationRequestUseCaseProtocol {
  func execute(url: URL) async throws -> PresentationRequestContext
}

// MARK: - PresentationError

enum PresentationError: Error {
  case invalidPresentationRequest
}

extension PresentationError {
  public static func ~= (lhs: Self, rhs: Error) -> Bool {
    guard let selfError = rhs as? Self else { return false }
    return selfError == lhs
  }
}

// MARK: - ProcessPresentationRequestUseCase

struct ProcessPresentationRequestUseCase: ProcessPresentationRequestUseCaseProtocol {

  // MARK: Internal

  func execute(url: URL) async throws -> PresentationRequestContext {
    let requestObject = try await fetchAndValidateRequestObject(from: url)
    let context = try await createPresentationContext(with: requestObject)
    await enrichContextWithTrustStatement(context: context, requestObject: requestObject)
    return try ensureContextHasCompatibleCredentials(context)
  }

  // MARK: Private

  @Injected(\.fetchRequestObjectUseCase) private var fetchRequestObjectUseCase: FetchRequestObjectUseCaseProtocol
  @Injected(\.validateRequestObjectUseCase) private var validateRequestObjectUseCase: ValidateRequestObjectUseCaseProtocol
  @Injected(\.denyPresentationUseCase) private var denyPresentationUseCase: DenyPresentationUseCaseProtocol
  @Injected(\.fetchTrustStatementUseCase) private var fetchTrustStatementUseCase: FetchTrustStatementUseCaseProtocol
  @Injected(\.getCompatibleCredentialsUseCase) private var getCompatibleCredentialsUseCase: GetCompatibleCredentialsUseCaseProtocol

  private func fetchAndValidateRequestObject(from url: URL) async throws -> RequestObject {
    let requestObject = try await fetchRequestObjectUseCase.execute(url)
    try await validate(requestObject: requestObject)
    return requestObject
  }

  private func createPresentationContext(with requestObject: RequestObject) async throws -> PresentationRequestContext {
    let compatibleCredentialsRequests = try await getCompatibleCredentialsUseCase.execute(using: requestObject)
    return PresentationRequestContext(requestObject: requestObject, requests: compatibleCredentialsRequests)
  }

  private func enrichContextWithTrustStatement(context: PresentationRequestContext, requestObject: RequestObject) async {
    if let jwtRequestObject = requestObject as? JWTRequestObject {
      let trustStatement = try? await fetchTrustStatementUseCase.execute(issuer: jwtRequestObject.issuer)
      context.trustStatement = trustStatement
    }
  }

  private func ensureContextHasCompatibleCredentials(_ context: PresentationRequestContext) throws -> PresentationRequestContext {
    if context.hasCompatibleCredentials {
      return context
    }

    guard
      let id = context.requestObject.firstInputDescriptor?.id,
      let credential = context.compatibleCredentialsRequestMap[id]?.first
    else {
      throw PresentationError.invalidPresentationRequest
    }

    context.selectedCredentials[id] = credential
    return context
  }

  private func validate(requestObject: RequestObject) async throws {
    guard await validateRequestObjectUseCase.execute(requestObject) else {
      try await denyPresentationUseCase.execute(requestObject: requestObject, error: .invalidRequest)
      throw FetchRequestObjectError.invalidPresentationInvitation
    }
  }

}
