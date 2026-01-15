import BITAppAttestation
import BITNetworking
import BITOpenID
import Factory
import Foundation

// MARK: - NonComplianceRepository

struct NonComplianceRepository: NonComplianceRepositoryProtocol {

  // MARK: Internal

  func create(_ report: NonComplianceReport) async throws {
    let body = try reportBodyGenerator.generate(from: report)
    let clientAttestationPlugin = try await generateClientAttestationPlugin(for: body)

    try await networkService.request(NonComplianceEndpoint.report(body), plugins: [clientAttestationPlugin])
  }

  func fetchNonCompliantActor(for subjectDid: String) async throws -> NonCompliantActor? {
    let trustRegistryURL = try trustRegistryUrlMapper.map(did: subjectDid)
    let response: NonCompliantActorsResponse = try await networkService.request(NonComplianceEndpoint.nonCompliantActors(url: trustRegistryURL))
    let actors = response.nonCompliantActors.map(NonCompliantActor.init)
    return actors.first { $0.did == subjectDid }
  }

  // MARK: Private

  @Injected(\NetworkContainer.service) private var networkService: NetworkService
  @Injected(\.nonComplianceBaseURL) private var baseURL
  @Injected(\.proofOfPossessionGenerator) private var proofOfPossessionGenerator
  @Injected(\.nonComplianceReportRequestBodyGenerator) private var reportBodyGenerator: NonComplianceReportRequestBodyGeneratorProtocol
  @Injected(\.trustRegistryUrlMapper) private var trustRegistryUrlMapper: TrustRegistryUrlMapperProtocol

  private func generateClientAttestationPlugin(for body: Encodable) async throws -> ClientAttestationPlugin {
    let (clientAttestation, proofOfPossession) = try await proofOfPossessionGenerator.generate(
      for: body,
      audience: baseURL.absoluteString,
      challengeEndpoint: URL(target: NonComplianceEndpoint.challenge))

    return ClientAttestationPlugin(clientAttestation: clientAttestation.rawJWS, proofOfPossession: proofOfPossession.rawJWS)
  }
}
