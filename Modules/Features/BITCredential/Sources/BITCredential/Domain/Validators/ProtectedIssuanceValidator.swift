import BITAnalytics
import BITAnyCredentialFormat
import BITOpenID
import Factory
import Foundation
import Spyable

// MARK: - ProtectedIssuanceValidatorProtocol

@Spyable
protocol ProtectedIssuanceValidatorProtocol {
  func validate(anyCredential: AnyCredential, metadataWrapper: CredentialIssuerMetadataWrapper) async throws
}

// MARK: - ProtectedIssuanceValidator

struct ProtectedIssuanceValidator: ProtectedIssuanceValidatorProtocol {

  // MARK: Internal

  func validate(anyCredential: AnyCredential, metadataWrapper: CredentialIssuerMetadataWrapper) async throws {
    do {
      let statement = try await trustStatementRepository.fetchProtectedIssuanceTrustListStatement(for: anyCredential.issuer)
      try await trustStatementValidator.validate(statement)
      guard statement.payload.vctValues.contains(anyCredential.vcSchemaId) else {
        return
      }

      guard let authorizationTrustStatement = metadataWrapper.selectedCredential.protectedIssuanceAuthorizationTrustStatement else {
        try await validateV1IssuanceTrust(for: anyCredential)
        return
      }

      try await validateAuthorizationTrustStatement(authorizationTrustStatement, issuerDid: anyCredential.issuer, vct: anyCredential.vcSchemaId)
    } catch let error as GovernanceError {
      analytics.log(error)
      throw error
    }
  }

  // MARK: Private

  @Injected(\.trustStatementValidator) private var trustStatementValidator
  @Injected(\.trustInformationService) private var trustInformationService
  @Injected(\.trustStatementRepository) private var trustStatementRepository
  @Injected(\.analytics) private var analytics: AnalyticsProtocol

  private func validateV1IssuanceTrust(for anyCredential: AnyCredential) async throws {
    let vcSchemaTrust = await trustInformationService.fetchVcSchemaTrust(for: anyCredential.issuer, type: .issuance, vcSchemaId: anyCredential.vcSchemaId)
    guard vcSchemaTrust == .trusted else {
      throw GovernanceError.unauthorizedIssuance
    }
  }

  private func validateAuthorizationTrustStatement(_ statement: ProtectedIssuanceAuthorizationTrustStatement, issuerDid: String, vct: String) async throws {
    guard statement.payload.canIssue.vct == vct else {
      throw GovernanceError.unauthorizedIssuance
    }

    do {
      try await trustStatementValidator.validate(statement, for: issuerDid)
    } catch {
      throw GovernanceError.unauthorizedIssuance
    }
  }
}
