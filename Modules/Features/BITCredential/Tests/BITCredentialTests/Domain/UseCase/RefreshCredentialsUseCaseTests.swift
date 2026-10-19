import Factory
import XCTest
@testable import BITActivity
@testable import BITAnyCredentialFormat
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITOpenID
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

final class RefreshCredentialsUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    registerMocks()
    useCase = RefreshCredentialsUseCase()
    createSuccessState()
  }

  func testCallAsFunction_success_assertCount() async throws {
    let result = try await useCase()

    XCTAssertEqual(result.count, mockVerifiableCredentials.count + mockDeferredCredentials.count)

    XCTAssertEqual(credentialRepository.getAllDeferredCredentialsCallsCount, 1)
    XCTAssertEqual(credentialRepository.getAllVerifiableCredentialsCallsCount, 2)
    XCTAssertEqual(credentialRepository.getAllCallsCount, 1)
    XCTAssertEqual(refreshDeferredCredentialUseCase.executeCallsCount, 1)
    XCTAssertEqual(refreshVerifiableCredentialsUseCase.callAsFunctionCallsCount, 1)
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.callAsFunctionCallsCount, 1)
  }

  func testCallAsFunction_success_assertParameters() async throws {
    _ = try await useCase.callAsFunction()

    XCTAssertEqual(refreshDeferredCredentialUseCase.executeReceivedCredentials, mockDeferredCredentials)
    XCTAssertEqual(refreshVerifiableCredentialsUseCase.callAsFunctionReceivedCredentials, mockVerifiableCredentials)
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.callAsFunctionReceivedCredentials, refreshedVerifiableCredentials)
  }

  func testCallAsFunction_getAllDeferredCredentialsFails_throwsError() async throws {
    credentialRepository.getAllDeferredCredentialsThrowableError = TestingError.error

    do {
      _ = try await useCase.callAsFunction()
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testCallAsFunction_refreshUseCaseFails_throwsError() async throws {
    refreshDeferredCredentialUseCase.executeThrowableError = TestingError.error

    do {
      _ = try await useCase.callAsFunction()
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testCallAsFunction_getAllVerifiableCredentialsFails_throwsError() async throws {
    credentialRepository.getAllVerifiableCredentialsThrowableError = TestingError.error

    do {
      _ = try await useCase.callAsFunction()
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testCallAsFunction_checkAndUpdateUseCaseFails_throwsError() async throws {
    checkAndUpdateCredentialStatusUseCase.callAsFunctionThrowableError = TestingError.error

    do {
      _ = try await useCase.callAsFunction()
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testCallAsFunction_getAllCredentialsFails_throwsError() async throws {
    credentialRepository.getAllThrowableError = TestingError.error

    do {
      _ = try await useCase.callAsFunction()
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private var useCase: RefreshCredentialsUseCase!

  private var credentialRepository: CredentialRepositoryProtocolSpy!
  private var refreshDeferredCredentialUseCase: RefreshDeferredCredentialUseCaseProtocolSpy!
  private var refreshVerifiableCredentialsUseCase: RefreshVerifiableCredentialsUseCaseProtocolSpy!
  private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocolSpy!

  private let mockDeferredCredentials = [DeferredCredential.Mock.sample, DeferredCredential.Mock.sampleWithoutMetadata]
  private let mockVerifiableCredentials = [VerifiableCredential.Mock.sample, VerifiableCredential.Mock.diploma]
  private let refreshedVerifiableCredentials = [VerifiableCredential.Mock.sampleDisplaysAdditional]

  private func registerMocks() {
    let credentialRepository = CredentialRepositoryProtocolSpy()
    self.credentialRepository = credentialRepository
    let refreshDeferredCredentialUseCase = RefreshDeferredCredentialUseCaseProtocolSpy()
    self.refreshDeferredCredentialUseCase = refreshDeferredCredentialUseCase
    let refreshVerifiableCredentialsUseCase = RefreshVerifiableCredentialsUseCaseProtocolSpy()
    self.refreshVerifiableCredentialsUseCase = refreshVerifiableCredentialsUseCase
    let checkAndUpdateCredentialStatusUseCase = CheckAndUpdateCredentialStatusUseCaseProtocolSpy()
    self.checkAndUpdateCredentialStatusUseCase = checkAndUpdateCredentialStatusUseCase

    Container.shared.credentialRepository.register { credentialRepository }
    Container.shared.refreshDeferredCredentialUseCase.register { refreshDeferredCredentialUseCase }
    Container.shared.refreshVerifiableCredentialsUseCase.register { refreshVerifiableCredentialsUseCase }
    Container.shared.checkAndUpdateCredentialStatusUseCase.register { checkAndUpdateCredentialStatusUseCase }
  }

  private func createSuccessState() {
    credentialRepository.getAllDeferredCredentialsReturnValue = mockDeferredCredentials
    credentialRepository.getAllVerifiableCredentialsClosure = {
      self.credentialRepository.getAllVerifiableCredentialsCallsCount == 1 ?
        self.mockVerifiableCredentials :
        self.refreshedVerifiableCredentials
    }
    checkAndUpdateCredentialStatusUseCase.callAsFunctionReturnValue = mockVerifiableCredentials
    credentialRepository.getAllReturnValue = mockDeferredCredentials + mockVerifiableCredentials
  }

}
