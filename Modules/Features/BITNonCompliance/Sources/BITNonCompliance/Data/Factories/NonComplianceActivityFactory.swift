import BITEntities
import Foundation
import Spyable

// MARK: - NonComplianceActivityFactoryProtocol

@Spyable
public protocol NonComplianceActivityFactoryProtocol: Sendable {
  func callAsFunction(_ entity: CredentialActivityEntity) throws -> NonComplianceActivity
}

// MARK: - NonComplianceActivityFactory

struct NonComplianceActivityFactory: NonComplianceActivityFactoryProtocol {

  func callAsFunction(_ entity: CredentialActivityEntity) throws -> NonComplianceActivity {
    guard !entity.issuer.isEmpty else { throw NonComplianceActivityFactoryError.issuerNotFound }

    return NonComplianceActivity(
      nonComplianceData: entity.nonComplianceData,
      createdAt: entity.createdAt,
      issuer: entity.issuer)
  }
}

// MARK: - NonComplianceActivityFactoryError

enum NonComplianceActivityFactoryError: Error {
  case issuerNotFound
}
