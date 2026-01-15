import BITCore
import BITNonCompliance
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

    let actorCompliance = await fetchActorCompliance(for: subjectDid)

    return TrustInformation(identity: identityTrust, vcSchema: vcSchemaTrust, actorCompliance: actorCompliance)
  }

  // MARK: Private

  @Injected(\.trustStatementService) private var trustStatementService
  @Injected(\.nonComplianceRepository) private var nonComplianceRepository: NonComplianceRepositoryProtocol

  private func fetchIdentityTrust(for subjectDid: String) async -> IdentityTrust {
    do {
      let statement = try await trustStatementService.fetchIdentity(for: subjectDid).resolvedPayload
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

  private func fetchActorCompliance(for subjectDid: String) async -> ActorCompliance {
    // errors or empty should not display warning badge
    guard let actor = try? await nonComplianceRepository.fetchNonCompliantActor(for: subjectDid) else { return .compliant }
    return .notCompliant(LocalizedNonComplianceReason(values: actor.reason))
  }
}
