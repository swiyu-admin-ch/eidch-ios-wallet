import Factory
import Testing
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore

struct GetCredentialListUseCaseTests {

  // MARK: Lifecycle

  init() {
    let credentialRepository = CredentialRepositoryProtocolSpy()

    Container.shared.credentialRepository.register { credentialRepository }

    useCase = GetCredentialListUseCase()
    self.credentialRepository = credentialRepository
  }

  // MARK: Internal

  func testExecuteSucces() async throws {
    credentialRepository.getAllReturnValue = mockCredentials

    let credentials = try await useCase()

    #expect(credentials.count == mockCredentials.count)
    #expect(credentialRepository.getAllCalled == true)
  }

  func testExecuteWithRepositoryError() async throws {
    credentialRepository.getAllThrowableError = TestingError.error

    do {
      _ = try await useCase()
    } catch {
      #expect(credentialRepository.getAllCalled == true)
    }
  }

  // MARK: Private

  private let useCase: GetCredentialListUseCase
  private let mockCredentials: [VerifiableCredential] = [.Mock.sample, .Mock.sampleDisplaysAdditional, .Mock.diploma]
  private let credentialRepository: CredentialRepositoryProtocolSpy

}
