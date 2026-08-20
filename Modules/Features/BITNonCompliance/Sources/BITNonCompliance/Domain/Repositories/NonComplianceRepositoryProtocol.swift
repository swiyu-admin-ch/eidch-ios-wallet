import BITActivity
import Foundation
import Spyable

@Spyable
public protocol NonComplianceRepositoryProtocol {
  func create(_ report: NonComplianceReport) async throws
  func fetchActorCompliance(for subjectDid: String) async throws -> ActorCompliance
  func getActivity(_ id: UUID) throws -> NonComplianceActivity
  func getActivityActorDisplay(_ id: UUID) throws -> ActivityActorDisplay?
}
