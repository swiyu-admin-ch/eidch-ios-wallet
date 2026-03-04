import Factory
import XCTest
@testable import BITCredential
@testable import BITNonCompliance
@testable import BITOpenID
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional

final class TrustInformationServiceTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    service = TrustInformationService()
    setupSuccessState()
  }

  // MARK: - testFetch identity

  func testFetch_validIdentityAndIssuanceStatement_returnsTrusted() async {
    let result = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertEqual(result.identity, .trusted(identityMock.resolvedPayload))
    XCTAssertEqual(result.vcSchema, .trusted)
    XCTAssertEqual(result.actorCompliance, .compliant)
  }

  func testFetch_validIdentityAndIssuanceStatement_argumentsPassed() async {
    _ = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertEqual(statementServiceSpy.fetchIdentityForCallsCount, 1)
    XCTAssertEqual(statementServiceSpy.fetchIdentityForReceivedSubjectDid, subjectDidMock)

    XCTAssertEqual(statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdCallsCount, 1)
    XCTAssertEqual(statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdReceivedArguments?.subjectDid, subjectDidMock)
    XCTAssertEqual(statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdReceivedArguments?.type, vcSchemaTypeMock)
    XCTAssertEqual(statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdReceivedArguments?.vcSchemaId, vcSchemaIdMock)
  }

  func testFetch_validIdentityAndNoVcSchemaId_returnsIdentityTrusted() async {
    let result = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: nil)

    XCTAssertEqual(result.identity, .trusted(identityMock.resolvedPayload))
    XCTAssertEqual(result.vcSchema, .notProtected)
  }

  func testFetch_validIdentityAndNoVcSchemaId_argumentsPassed() async {
    _ = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: nil)

    XCTAssertEqual(statementServiceSpy.fetchIdentityForCallsCount, 1)
    XCTAssertEqual(statementServiceSpy.fetchIdentityForReceivedSubjectDid, subjectDidMock)

    XCTAssertEqual(statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdCallsCount, 0)
  }

  func testFetch_unknownSubjectDid_returnsUnknown() async {
    let result = await service.fetch(for: "unknown", type: vcSchemaTypeMock, vcSchemaId: nil)

    XCTAssertEqual(result.identity, .unknown)
    XCTAssertEqual(result.vcSchema, .notProtected)
  }

  func testFetch_unknownSubjectDid_argumentsPassed() async {
    _ = await service.fetch(for: "unknown", type: vcSchemaTypeMock, vcSchemaId: nil)

    XCTAssertEqual(statementServiceSpy.fetchIdentityForCallsCount, 0)
    XCTAssertEqual(statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdCallsCount, 0)
  }

  func testFetch_fetchVcSchemaReturnsNil_returnsNotProtectedVcSchema() async {
    statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdReturnValue = nil

    let result = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertEqual(result.identity, .trusted(identityMock.resolvedPayload))
    XCTAssertEqual(result.vcSchema, .notProtected)
    XCTAssertEqual(result.actorCompliance, .compliant)
  }

  func testFetch_fetchIdentityThrowsError_returnsUntrustedIdentity() async {
    statementServiceSpy.fetchIdentityForThrowableError = TestingError.error

    let result = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertEqual(result.identity, .untrusted)
    XCTAssertEqual(result.vcSchema, .trusted)
    XCTAssertEqual(result.actorCompliance, .compliant)
  }

  func testFetch_fetchVcSchemaThrowsValidationError_returnsUntrustedVcSchema() async {
    statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdThrowableError = TrustStatementServiceError.validationFailed

    let result = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertEqual(result.identity, .trusted(identityMock.resolvedPayload))
    XCTAssertEqual(result.vcSchema, .untrusted)
    XCTAssertEqual(result.actorCompliance, .compliant)
  }

  func testFetch_fetchVcSchemaThrowsError_returnsNotProtectedVcSchema() async {
    statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdThrowableError = TestingError.error

    let result = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertEqual(result.identity, .trusted(identityMock.resolvedPayload))
    XCTAssertEqual(result.vcSchema, .notProtected)
  }

  func testFetch_notCompliantActor_returnsNotCompliantActor() async {
    let reasonMock = ["en": "reason EN"]
    nonComplianceRepositorySpy.fetchNonCompliantActorForReturnValue = NonCompliantActor(reason: reasonMock, did: subjectDidMock)

    let result = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertEqual(result.actorCompliance, .notCompliant(LocalizedNonComplianceReason(values: reasonMock)))
  }

  func testFetch_fetchNonCompliantActorThrowsError_returnsCompliantActorCompliance() async {
    nonComplianceRepositorySpy.fetchNonCompliantActorForThrowableError = TestingError.error

    let result = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertEqual(result.actorCompliance, .compliant)
  }

  // MARK: Private

  private let subjectDidMock = "did:tdw:mock:identifier-reg.trust-infra.swiyu.admin.ch:example"
  private let vcSchemaIdMock = "vcSchemaId"
  private let vcSchemaTypeMock = VcSchemaTrustStatementType.issuance
  private let identityMock = IdentityTrustStatementJWT.Mock.validSample
  private let vcSchemaMock = VcSchemaTrustStatementJWT.Mock.validSample

  private var statementServiceSpy: TrustStatementServiceProtocolSpy!
  private var nonComplianceRepositorySpy: NonComplianceRepositoryProtocolSpy!

  private var service: TrustInformationService!

  private func registerMocks() {
    statementServiceSpy = TrustStatementServiceProtocolSpy()
    nonComplianceRepositorySpy = NonComplianceRepositoryProtocolSpy()

    Container.shared.trustStatementService.register { self.statementServiceSpy }
    Container.shared.nonComplianceRepository.register { self.nonComplianceRepositorySpy }
  }

  private func setupSuccessState() {
    statementServiceSpy.fetchIdentityForReturnValue = identityMock
    statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdReturnValue = vcSchemaMock
  }
}
