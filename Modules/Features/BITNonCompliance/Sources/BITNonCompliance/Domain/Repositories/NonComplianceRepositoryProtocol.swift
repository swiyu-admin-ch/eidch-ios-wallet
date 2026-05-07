import BITActivity
import Foundation
import Spyable

@Spyable
public protocol NonComplianceRepositoryProtocol {
  func create(_ report: NonComplianceReport) async throws
  func fetchNonCompliantActor(for subjectDid: String) async throws -> NonCompliantActor?
  func getActivity(_ id: UUID) throws -> NonComplianceActivity
  func getActivityActorDisplay(_ id: UUID) throws -> ActivityActorDisplay?
}
