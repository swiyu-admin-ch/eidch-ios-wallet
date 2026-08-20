import BITAnalytics
import BITClaimsPathPointer
import Factory
import Foundation
import Spyable

// MARK: - ValidateVerificationAuthorizationTrustStatementUseCaseProtocol

@Spyable
public protocol ValidateVerificationAuthorizationTrustStatementUseCaseProtocol {
  func callAsFunction(requestObject: RequestObject, requestedClaims: [ClaimsPathPointer]) async throws
}

// MARK: - ValidateVerificationAuthorizationTrustStatementUseCaseError

public enum ValidateVerificationAuthorizationTrustStatementUseCaseError: Error, Equatable {
  case unauthorizedVerification(presentationResponse: PresentationResponse? = nil)
}

// MARK: - ValidateVerificationAuthorizationTrustStatementUseCase

struct ValidateVerificationAuthorizationTrustStatementUseCase: ValidateVerificationAuthorizationTrustStatementUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(requestObject: RequestObject, requestedClaims: [ClaimsPathPointer]) async throws {
    #warning("Remove once TP 2.0 is enforced")
    guard requestObject.identityTrustStatement != nil else { return }

    do {
      let protectedClaims = getProtectedClaims(requestedClaims)
      guard !protectedClaims.isEmpty else { return }

      guard
        let trustStatement = requestObject.protectedVerificationAuthorizationTrustStatement,
        protectedClaims.allSatisfy(trustStatement.payload.authorizedFields.contains)
      else {
        throw GovernanceError.unauthorizedVerification
      }

      try await trustStatementValidator.validate(trustStatement, for: requestObject.clientIdentifier.clientId)
    } catch {
      let error = GovernanceError.unauthorizedVerification
      analytics.log(error)
      let presentationResponse = try await declineRequest(requestObject)
      throw ValidateVerificationAuthorizationTrustStatementUseCaseError.unauthorizedVerification(presentationResponse: presentationResponse)
    }
  }

  // MARK: Private

  @Injected(\.trustStatementValidator) private var trustStatementValidator
  @Injected(\.protectedVerificationClaims) private var protectedVerificationClaims
  @Injected(\.presentationRequestService) private var presentationRequestService
  @Injected(\.analytics) private var analytics: AnalyticsProtocol

  private func getProtectedClaims(_ requestedClaims: [ClaimsPathPointer]) -> [String] {
    requestedClaims.flatMap { path in
      path.compactMap { component in
        if case .string(let string) = component, protectedVerificationClaims.contains(string) {
          return string
        }
        return nil
      }
    }.uniqued()
  }

  private func declineRequest(_ requestObject: RequestObject) async throws -> PresentationResponse? {
    guard let url = requestObject.responseUri else { return nil }

    do {
      return try await presentationRequestService.decline(url: url, with: .accessDenied)
    } catch let error as PresentationResponseValidationError {
      throw error
    } catch {
      return nil
    }
  }
}
