import Testing
@testable import BITAppAttestation

struct DisabledAppAttestationRepositoryTests {

  // MARK: Internal

  @Test
  func fetchChallenge_throwsServiceDeactivated() async {
    await #expect(throws: AttestationServiceRepositoryError.serviceDeactivated) {
      try await repository.fetchChallenge()
    }
  }

  @Test
  func fetchClientAttestation_throwsServiceDeactivated() async {
    await #expect(throws: AttestationServiceRepositoryError.serviceDeactivated) {
      try await repository.fetchClientAttestation(ClientAttestationRequestBody.Mock.sample)
    }
  }

  @Test
  func fetchKeyAttestation_throwsServiceDeactivated() async {
    await #expect(throws: AttestationServiceRepositoryError.serviceDeactivated) {
      try await repository.fetchKeyAttestation(
        body: KeyAttestationRequestBody.Mock.sample,
        clientAttestation: ClientAttestationJWT.Mock.sample)
    }
  }

  @Test
  func fetchBatchKeyAttestation_throwsServiceDeactivated() async {
    await #expect(throws: AttestationServiceRepositoryError.serviceDeactivated) {
      try await repository.fetchBatchKeyAttestation(
        body: [KeyAttestationRequestBody.Mock.sample],
        clientAttestation: ClientAttestationJWT.Mock.sample)
    }
  }

  // MARK: Private

  private let repository = DisabledAppAttestationRepository()

}
