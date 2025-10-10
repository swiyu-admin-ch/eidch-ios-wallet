import BITCore
import BITOpenID
import Factory
import Foundation
import Spyable

// MARK: - TrustInformationServiceProtocol

@Spyable
public protocol TrustInformationServiceProtocol {
  func fetch(for subjectDid: String, type: VcSchemaTrustStatementType, vcSchemaId: String?) async -> TrustInformation
}

// MARK: - TrustInformationService

struct TrustInformationService: TrustInformationServiceProtocol {

  // MARK: Internal

  func fetch(for subjectDid: String, type: VcSchemaTrustStatementType, vcSchemaId: String?) async -> TrustInformation {
    let identityTrust = await fetchIdentityTrust(for: subjectDid)
    let vcSchemaTrust: VcSchemaTrust = if let vcSchemaId {
      await fetchVcSchemaTrust(for: subjectDid, type: type, vcSchemaId: vcSchemaId)
    } else {
      .notProtected
    }
    return TrustInformation(identity: identityTrust, vcSchema: vcSchemaTrust)
  }

  // MARK: Private

  @Injected(\.trustStatementService) private var trustStatementService
  @Injected(\.isIdentityTrustStatementEnabled) private var isIdentityTrustStatementEnabled: Bool

  private func fetchIdentityTrust(for subjectDid: String) async -> IdentityTrust {
    do {
      let statement: (any LocalizedTrustStatement) = if isIdentityTrustStatementEnabled {
        try await trustStatementService.fetchIdentity(for: subjectDid).resolvedPayload
      } else {
        try await trustStatementService.fetchMetadata(for: subjectDid).resolvedPayload
      }
      return .trusted(statement)
    } catch { // errors here should not stop flow of caller
      return .untrusted
    }
  }

  private func fetchVcSchemaTrust(for subjectDid: String, type: VcSchemaTrustStatementType, vcSchemaId: String) async -> VcSchemaTrust {
    do {
      let statement = try await trustStatementService.fetchVcSchema(for: subjectDid, type: type, vcSchemaId: vcSchemaId)
      return statement != nil ? .trusted : .notProtected
    } catch TrustStatementServiceError.validationFailed {
      return .untrusted
    } catch { // errors here should not stop flow of caller
      return .notProtected
    }
  }
}
