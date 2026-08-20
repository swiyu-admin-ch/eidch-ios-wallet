import BITActivity
import BITAppAttestation
import BITAppAuth
import BITEntities
import BITJWT
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

  func fetchActorCompliance(for subjectDid: String) async throws -> ActorCompliance {
    let trustRegistryURL = try trustRegistryUrlMapper.map(did: subjectDid)
    let response = try await networkService.request(NonComplianceEndpoint.nonComplianceTrustList(url: trustRegistryURL))
    let statement = try jwsDecoder.decode(NonComplianceTrustListStatementJWT.self, from: response.data)
    try await trustStatementValidator.validate(statement)

    guard let actor = statement.payload.nonCompliantActors.first(where: { $0.actor == subjectDid }) else {
      return .compliant
    }
    return .notCompliant(actor.reason)
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

  @Injected(\.activityActorDisplayFactory) private var activityActorDisplayFactory
  @Injected(\.clientAttestationRepository) private var clientAttestationRepository
  @Injected(\.dataStore) private var database
  @Injected(\.jwsDecoder) private var jwsDecoder
  @Injected(\NetworkContainer.service) private var networkService
  @Injected(\.nonComplianceActivityFactory) private var nonComplianceActivityFactory
  @Injected(\.nonComplianceBaseURL) private var baseURL
  @Injected(\.nonComplianceJsonEncoder) private var nonComplianceJsonEncoder
  @Injected(\.nonComplianceReportRequestBodyGenerator) private var reportBodyGenerator
  @Injected(\.proofOfPossessionGenerator) private var proofOfPossessionGenerator
  @Injected(\.trustRegistryUrlMapper) private var trustRegistryUrlMapper
  @Injected(\.trustStatementValidator) private var trustStatementValidator
  @Injected(\.userSession) private var userSession

  private func generateClientAttestationPlugin(for body: Encodable) async throws -> ClientAttestationPlugin {
    let clientAttestation = try await clientAttestationRepository.get(using: userContext())
    let proofOfPossession = try await proofOfPossessionGenerator(
      for: body,
      audience: baseURL.absoluteString,
      challengeEndpoint: URL(target: NonComplianceEndpoint.challenge),
      clientAttestation: clientAttestation,
      encoder: nonComplianceJsonEncoder)

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
