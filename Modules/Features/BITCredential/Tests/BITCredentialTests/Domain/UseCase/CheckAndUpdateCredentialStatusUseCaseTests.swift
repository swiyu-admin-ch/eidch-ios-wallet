// swiftlint:disable implicitly_unwrapped_optional force_try

import Factory
import Foundation
import Testing
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore

@Suite
struct CheckAndUpdateCredentialStatusUseCaseTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    registerMocks()

    useCase = CheckAndUpdateCredentialStatusUseCase()

    validator.callAsFunctionReturnValue = .revoked
    selectCredentialBundleItemUseCase.callAsFunctionClosure = {
      guard let first = $0.bundleItems.first else { throw CredentialError.noBundleItem }
      return first
    }
    credentialRepository.updateVerifiableCredentialReturnValue = credential1Mock
  }

  // MARK: Internal

  // MARK: Tests

  @Test
  func callAsFunctionFor_statusChanged_updatesCredential() async throws {
    validator.callAsFunctionReturnValue = .revoked

    let result = try await useCase(for: credentialMock)

    #expect(result == credential1Mock)
    var updatedCredential = credentialMock
    updatedCredential.bundleItems[0].status = .revoked
    #expect(validator.callAsFunctionCallsCount == 1)
    #expect(validator.callAsFunctionReceivedCredential == credentialMock)
    #expect(credentialRepository.updateVerifiableCredentialCallsCount == 1)
    #expect(credentialRepository.updateVerifiableCredentialReceivedVerifiableCredential == updatedCredential)
  }

  @Test
  func callAsFunctionFor_sameStatus_doesNotUpdateCredential() async throws {
    validator.callAsFunctionReturnValue = .valid

    let result = try await useCase(for: credentialMock)

    #expect(result == credentialMock)
    #expect(credentialRepository.updateVerifiableCredentialCalled == false)
  }

  @Test
  func callAsFunctionFor_unknownStatus_doesNotUpdateCredential() async throws {
    validator.callAsFunctionReturnValue = .unknown

    let result = try await useCase(for: credentialMock)

    #expect(result == credentialMock)
    #expect(credentialRepository.updateVerifiableCredentialCalled == false)
  }

  @Test
  func callAsFunctionFor_selectBundleItemThrows_rethrowsError() async {
    selectCredentialBundleItemUseCase.callAsFunctionThrowableError = TestingError.error

    await #expect(throws: TestingError.self) {
      _ = try await useCase(for: credentialMock)
    }
    #expect(credentialRepository.updateVerifiableCredentialCalled == false)
  }

  @Test
  func callAsFunctionFor_repositoryThrows_rethrowsError() async {
    credentialRepository.updateVerifiableCredentialThrowableError = TestingError.error

    await #expect(throws: TestingError.self) {
      _ = try await useCase(for: credentialMock)
    }
  }

  @Test
  func executeBatch_allSucceed_returnsUpdatedCredentials() async throws {
    credentialRepository.updateVerifiableCredentialClosure = { credential in
      var updated = credential
      if credential.id == credentialMock.id {
        updated.bundleItems[0].status = .revoked
      } else {
        updated.bundleItems[0].status = .suspended
      }
      return updated
    }

    let result = try await useCase([credentialMock, credential1Mock])

    #expect(validator.callAsFunctionCallsCount == 2)
    #expect(result.count == 2)
    #expect(result[0].id == credentialMock.id)
    #expect(result[0].bundleItems.first?.status == .revoked)
    #expect(result[1].id == credential1Mock.id)
    #expect(result[1].bundleItems.first?.status == .suspended)
  }

  @Test
  func executeBatch_mixedSuccessAndFailure_returnsCorrectCredentials() async throws {
    validator.callAsFunctionClosure = { credential in
      switch credential.id {
      case credentialMock.id:
        return .revoked
      case credential1Mock.id:
        throw TestingError.error
      default:
        return .suspended
      }
    }
    credentialRepository.updateVerifiableCredentialClosure = { $0 }

    let result = try await useCase([credentialMock, credential1Mock, credential2Mock])

    #expect(result.count == 3)
    #expect(credentialRepository.updateVerifiableCredentialCallsCount == 2)

    #expect(result[0].id == credentialMock.id)
    #expect(result[0].bundleItems.first?.status == .revoked)
    #expect(result[1] == credential1Mock)
    #expect(result[2].id == credential2Mock.id)
    #expect(result[2].bundleItems.first?.status == .suspended)
  }

  @Test
  func executeBatch_allFail_returnsOriginalCredentials() async throws {
    validator.callAsFunctionThrowableError = TestingError.error

    let result = try await useCase([credentialMock, credential1Mock])

    #expect(result.count == 2)
    #expect(result[0] == credentialMock)
    #expect(result[1] == credential1Mock)
    #expect(credentialRepository.updateVerifiableCredentialCalled == false)
  }

  // MARK: Private

  private let credentialMock = VerifiableCredential.Mock.sample
  private let credential1Mock = VerifiableCredential.Mock.diploma
  private let credential2Mock = VerifiableCredential.Mock.displaysThemed

  private var useCase: CheckAndUpdateCredentialStatusUseCase!

  private var validator: CredentialStatusValidatorProtocolSpy!
  private var credentialRepository: CredentialRepositoryProtocolSpy!
  private var selectCredentialBundleItemUseCase: SelectCredentialBundleItemUseCaseProtocolSpy!

  private mutating func registerMocks() {
    let validator = CredentialStatusValidatorProtocolSpy()
    let credentialRepository = CredentialRepositoryProtocolSpy()
    let selectCredentialBundleItemUseCase = SelectCredentialBundleItemUseCaseProtocolSpy()

    self.validator = validator
    self.credentialRepository = credentialRepository
    self.selectCredentialBundleItemUseCase = selectCredentialBundleItemUseCase

    Container.shared.credentialStatusValidator.register { validator }
    Container.shared.credentialRepository.register { credentialRepository }
    Container.shared.selectCredentialBundleItemUseCase.register { selectCredentialBundleItemUseCase }
  }
}
