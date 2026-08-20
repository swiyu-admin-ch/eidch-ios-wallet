import Factory
import XCTest
@testable import BITActivity
@testable import BITCore
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITNonCompliance
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

final class AcceptCredentialUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    registerMocks()
    useCase = AcceptCredentialUseCase()
    createSuccess()
  }

  func testUseCase_success_returnsCredential() async throws {
    let result = try await useCase(mockCredential, trustInformation: trustInformation, actorCompliance: actorCompliance)

    XCTAssertEqual(result, updateCredential)
  }

  func testUseCase_success_assertParameters() async throws {
    _ = try await useCase(mockCredential, trustInformation: trustInformation, actorCompliance: actorCompliance)

    XCTAssertEqual(credentialRepositorySpy.updateVerifiableCredentialCallsCount, 1)
    XCTAssertEqual(credentialRepositorySpy.updateVerifiableCredentialReceivedVerifiableCredential?.id, mockCredential.id)
    XCTAssertEqual(credentialRepositorySpy.updateVerifiableCredentialReceivedVerifiableCredential?.progressionState, .accepted)

    XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 1)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.activity.actorTrust, trustInformation.actorTrust)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.activity.vcSchemaTrust, trustInformation.vcSchemaTrust)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.activity.actorCompliance, actorCompliance.actorComplianceStatus)
    XCTAssertEqual(
      activityServiceSpy.createCredentialIdReceivedArguments?.activity.nonComplianceReasonDisplays,
      actorCompliance.nonComplianceReasonDisplays)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.credentialId, mockCredential.id)
  }

  func testUseCase_activityServiceThrows_returnsCredential() async throws {
    activityServiceSpy.createCredentialIdThrowableError = TestingError.error

    let result = try await useCase(mockCredential, trustInformation: trustInformation, actorCompliance: actorCompliance)

    XCTAssertEqual(result, updateCredential)
  }

  func testUseCase_updateCredentialFails_throwsError() async throws {
    credentialRepositorySpy.updateVerifiableCredentialThrowableError = TestingError.error

    do {
      _ = try await useCase(mockCredential, trustInformation: trustInformation, actorCompliance: actorCompliance)
      XCTFail("Expected exception")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let mockCredential = VerifiableCredential.Mock.sample
  private let updateCredential = VerifiableCredential.Mock.diploma
  private let trustInformation = TrustInformation.Mock.fullyTrusted
  private let actorCompliance = ActorCompliance.notCompliant(LocalizedDisplay(values: ["en": "reason EN"]))

  private var useCase: AcceptCredentialUseCase!
  private var credentialRepositorySpy: CredentialRepositoryProtocolSpy!
  private var activityServiceSpy: ActivityServiceProtocolSpy!

  private func registerMocks() {
    credentialRepositorySpy = CredentialRepositoryProtocolSpy()
    activityServiceSpy = ActivityServiceProtocolSpy()
    Container.shared.credentialRepository.register { self.credentialRepositorySpy }
    Container.shared.activityService.register { self.activityServiceSpy }
  }

  private func createSuccess() {
    credentialRepositorySpy.updateVerifiableCredentialReturnValue = updateCredential
  }

}
