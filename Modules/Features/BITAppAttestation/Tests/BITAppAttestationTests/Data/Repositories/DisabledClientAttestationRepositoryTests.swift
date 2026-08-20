import Testing
@testable import BITAppAttestation
@testable import BITLocalAuthentication

struct DisabledClientAttestationRepositoryTests {

  // MARK: Internal

  @Test
  func get_throwsServiceDeactivated() async {
    await #expect(throws: AttestationServiceRepositoryError.serviceDeactivated) {
      try await repository.get(using: LAContextProtocolSpy())
    }
  }

  @Test
  func create_throwsServiceDeactivated() async {
    await #expect(throws: AttestationServiceRepositoryError.serviceDeactivated) {
      try await repository.create(ClientAttestationJWT.Mock.sample)
    }
  }

  @Test
  func delete_doesNotThrow() throws {
    try repository.delete()
  }

  // MARK: Private

  private let repository = DisabledClientAttestationRepository()

}
