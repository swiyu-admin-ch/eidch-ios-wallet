import Spyable

@Spyable
public protocol NonComplianceRepositoryProtocol {
  func create(_ report: NonComplianceReport) async throws
  func fetchNonCompliantActor(for subjectDid: String) async throws -> NonCompliantActor?
}
