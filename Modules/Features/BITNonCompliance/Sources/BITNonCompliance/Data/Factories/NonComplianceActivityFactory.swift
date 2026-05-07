import BITEntities
import Foundation
import Spyable

// MARK: - NonComplianceActivityFactoryProtocol

@Spyable
public protocol NonComplianceActivityFactoryProtocol {
  func callAsFunction(_ entity: CredentialActivityEntity) throws -> NonComplianceActivity
}

// MARK: - NonComplianceActivityFactory

struct NonComplianceActivityFactory: NonComplianceActivityFactoryProtocol {
  func callAsFunction(_ entity: CredentialActivityEntity) throws -> NonComplianceActivity {
    guard
      let credential = entity.credential.first,
      let verifiableCredential = credential.verifiableCredential
    else { throw NonComplianceActivityFactoryError.credentialNotFound }

    return NonComplianceActivity(
      nonComplianceData: entity.nonComplianceData,
      createdAt: entity.createdAt,
      issuer: verifiableCredential.issuer)
  }
}

// MARK: - NonComplianceActivityFactoryError

enum NonComplianceActivityFactoryError: Error {
  case credentialNotFound
}
