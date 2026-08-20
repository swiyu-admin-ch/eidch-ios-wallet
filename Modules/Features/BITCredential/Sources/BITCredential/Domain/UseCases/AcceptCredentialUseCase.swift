import BITActivity
import BITCredentialShared
import BITNonCompliance
import Factory
import Spyable

// MARK: - AcceptCredentialUseCaseProtocol

@Spyable
public protocol AcceptCredentialUseCaseProtocol {
  @discardableResult
  func callAsFunction(_ credential: VerifiableCredential, trustInformation: TrustInformation, actorCompliance: ActorCompliance) async throws -> VerifiableCredential
}

// MARK: - AcceptCredentialUseCase

struct AcceptCredentialUseCase: AcceptCredentialUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(_ credential: VerifiableCredential, trustInformation: TrustInformation, actorCompliance: ActorCompliance) async throws -> VerifiableCredential {
    var credentialCopy = credential
    credentialCopy.progressionState = .accepted
    let updatedCredential = try await credentialRepository.update(verifiableCredential: credentialCopy)
    let activity = Activity(credential: credentialCopy, trustInformation: trustInformation, actorCompliance: actorCompliance)
    try? activityService.create(activity, credentialId: credentialCopy.id)
    return updatedCredential
  }

  // MARK: Private

  @Injected(\.credentialRepository) private var credentialRepository
  @Injected(\.activityService) private var activityService
}
