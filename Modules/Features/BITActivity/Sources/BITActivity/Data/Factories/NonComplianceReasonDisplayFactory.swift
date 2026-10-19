import BITEntities
import Foundation
import Spyable

// MARK: - NonComplianceReasonDisplayFactoryProtocol

@Spyable
public protocol NonComplianceReasonDisplayFactoryProtocol: Sendable {
  func callAsFunction(_ entity: NonComplianceReasonDisplayEntity) -> NonComplianceReasonDisplay
}

// MARK: - NonComplianceReasonDisplayFactory

struct NonComplianceReasonDisplayFactory: NonComplianceReasonDisplayFactoryProtocol {
  func callAsFunction(_ entity: NonComplianceReasonDisplayEntity) -> NonComplianceReasonDisplay {
    NonComplianceReasonDisplay(
      locale: entity.locale,
      reason: entity.reason)
  }
}
