import BITActivity
import BITAppAttestation
import BITAppAuth
import BITCore
import BITEntities
import BITLocalAuthentication
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

  func getActivity(_ id: UUID) throws -> NonComplianceActivity {
    let entity = try getActivityEntity(id)
    return try nonComplianceActivityFactory(entity)
  }

  func getActivityActorDisplay(_ id: UUID) throws -> ActivityActorDisplay? {
    let entity = try getActivityEntity(id)
    let displays = Array(entity.actorDisplays.map(activityActorDisplayFactory.callAsFunction))
    return displays.findDisplayWithFallback()
  }

  // MARK: Private

  @Injected(\NetworkContainer.service) private var networkService: NetworkService
  @Injected(\.nonComplianceBaseURL) private var baseURL
  @Injected(\.proofOfPossessionGenerator) private var proofOfPossessionGenerator
  @Injected(\.clientAttestationRepository) private var clientAttestationRepository: ClientAttestationRepositoryProtocol
  @Injected(\.userSession) private var userSession: Session
  @Injected(\.nonComplianceReportRequestBodyGenerator) private var reportBodyGenerator: NonComplianceReportRequestBodyGeneratorProtocol
  @Injected(\.trustRegistryUrlMapper) private var trustRegistryUrlMapper: TrustRegistryUrlMapperProtocol
  @Injected(\.dataStore) private var database
  @Injected(\.activityActorDisplayFactory) private var activityActorDisplayFactory
  @Injected(\.nonComplianceActivityFactory) private var nonComplianceActivityFactory

  private func generateClientAttestationPlugin(for body: Encodable) async throws -> ClientAttestationPlugin {
    let clientAttestation = try await clientAttestationRepository.get(using: userContext())
    let proofOfPossession = try await proofOfPossessionGenerator(
      for: body,
      audience: baseURL.absoluteString,
      challengeEndpoint: URL(target: NonComplianceEndpoint.challenge),
      clientAttestation: clientAttestation)

    return ClientAttestationPlugin(clientAttestation: clientAttestation.rawJWS, proofOfPossession: proofOfPossession.rawJWS)
  }

  private func userContext() throws -> LAContextProtocol {
    guard userSession.isLoggedIn, let context = userSession.context else {
      throw UserSessionError.notLoggedIn
    }

    return context
  }

  private func getActivityEntity(_ id: UUID) throws -> CredentialActivityEntity {
    guard let entity = try database.get(CredentialActivityEntity.self, forPrimaryKey: id) else {
      throw NonComplianceRepositoryError.activityNotFound
    }
    return entity
  }
}

// MARK: - NonComplianceRepositoryError

enum NonComplianceRepositoryError: Error {
  case activityNotFound
}
