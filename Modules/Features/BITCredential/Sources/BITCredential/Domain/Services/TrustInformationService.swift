import BITCore
import BITOpenID
import Factory
import Foundation
import Spyable

// MARK: - TrustInformationServiceProtocol

@Spyable
public protocol TrustInformationServiceProtocol {
  func fetch(for subjectDid: String, type: VcSchemaTrustStatementType, vcSchemaId: String?) async -> TrustInformation
  func fetchVcSchemaTrust(for subjectDid: String, type: VcSchemaTrustStatementType, vcSchemaId: String) async -> VcSchemaTrust
  func getEntityNames(for subjectDid: String?) async -> [String: String]?
}

// MARK: - TrustInformationService

struct TrustInformationService: TrustInformationServiceProtocol {

  // MARK: Internal

  func fetch(for subjectDid: String, type: VcSchemaTrustStatementType, vcSchemaId: String?) async -> TrustInformation {
    let identityTrust: IdentityTrust = if TrustEnvironment(did: subjectDid) != .external {
      await fetchIdentityTrust(for: subjectDid)
    } else {
      .unknown
    }
    let vcSchemaTrust: VcSchemaTrust = if let vcSchemaId {
      await fetchVcSchemaTrust(for: subjectDid, type: type, vcSchemaId: vcSchemaId)
    } else {
      .notProtected
    }

    return TrustInformation(identity: identityTrust, vcSchema: vcSchemaTrust)
  }

  func fetchVcSchemaTrust(for subjectDid: String, type: VcSchemaTrustStatementType, vcSchemaId: String) async -> VcSchemaTrust {
    do {
      let statement = try await trustStatementService.fetchVcSchema(for: subjectDid, type: type, vcSchemaId: vcSchemaId)
      return statement != nil ? .trusted : .notProtected
    } catch TrustStatementServiceError.validationFailed {
      return .untrusted
    } catch { // errors here should not stop flow of caller
      return .notProtected
    }
  }

  func getEntityNames(for kid: String?) async -> [String: String]? {
    do {
      let issuerDid = try didResolverHelper.getDid(from: kid)
      let statement = try await trustStatementService.fetchIdentity(for: issuerDid).resolvedPayload
      return statement.entityNames
    } catch {
      // ignore all errors
      return nil
    }
  }

  // MARK: Private

  @Injected(\.trustStatementService) private var trustStatementService
  @Injected(\.didResolverHelper) private var didResolverHelper

  private func fetchIdentityTrust(for subjectDid: String) async -> IdentityTrust {
    do {
      _ = try await trustStatementService.fetchIdentity(for: subjectDid).resolvedPayload
      return .trusted
    } catch { // errors here should not stop flow of caller
      return .untrusted
    }
  }

}
