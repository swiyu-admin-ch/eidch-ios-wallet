import Factory
import XCTest
@testable import BITCore
@testable import BITCredential
@testable import BITJWT
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

  // MARK: - fetch

  func testFetch_validIdentityAndIssuanceStatement_returnsTrusted() async {
    let result = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertEqual(result.identity, .trusted)
    XCTAssertEqual(result.vcSchema, .trusted)
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

    XCTAssertEqual(result.identity, .trusted)
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

    XCTAssertEqual(result.identity, .trusted)
    XCTAssertEqual(result.vcSchema, .notProtected)
  }

  func testFetch_fetchIdentityThrowsError_returnsUntrustedIdentity() async {
    statementServiceSpy.fetchIdentityForThrowableError = TestingError.error

    let result = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertEqual(result.identity, .untrusted)
    XCTAssertEqual(result.vcSchema, .trusted)
  }

  func testFetch_fetchVcSchemaThrowsValidationError_returnsUntrustedVcSchema() async {
    statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdThrowableError = TrustStatementServiceError.validationFailed

    let result = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertEqual(result.identity, .trusted)
    XCTAssertEqual(result.vcSchema, .untrusted)
  }

  func testFetch_fetchVcSchemaThrowsError_returnsNotProtectedVcSchema() async {
    statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdThrowableError = TestingError.error

    let result = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertEqual(result.identity, .trusted)
    XCTAssertEqual(result.vcSchema, .notProtected)
  }

  // MARK: - fetchVcSchemaTrust

  func testFetchVcSchemaTrust_validStatement_returnsTrusted() async {
    let result = await service.fetchVcSchemaTrust(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertEqual(result, .trusted)
  }

  func testFetchVcSchemaTrust_validStatement_argumentsPassed() async {
    _ = await service.fetchVcSchemaTrust(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertEqual(statementServiceSpy.fetchIdentityForCallsCount, 0)
    XCTAssertEqual(statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdCallsCount, 1)
    XCTAssertEqual(statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdReceivedArguments?.subjectDid, subjectDidMock)
    XCTAssertEqual(statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdReceivedArguments?.type, vcSchemaTypeMock)
    XCTAssertEqual(statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdReceivedArguments?.vcSchemaId, vcSchemaIdMock)
  }

  func testFetchVcSchemaTrust_fetchVcSchemaReturnsNil_returnsNotProtected() async {
    statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdReturnValue = nil

    let result = await service.fetchVcSchemaTrust(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertEqual(result, .notProtected)
  }

  func testFetchVcSchemaTrust_fetchVcSchemaThrowsValidationError_returnsUntrusted() async {
    statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdThrowableError = TrustStatementServiceError.validationFailed

    let result = await service.fetchVcSchemaTrust(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertEqual(result, .untrusted)
  }

  func testFetchVcSchemaTrust_fetchVcSchemaThrowsError_returnsNotProtected() async {
    statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdThrowableError = TestingError.error

    let result = await service.fetchVcSchemaTrust(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertEqual(result, .notProtected)
  }

  // MARK: - getEntityNames

  func testGetEntityNames_success_returnsEntityNames() async {
    let result = await service.getEntityNames(for: kidMock)

    XCTAssertEqual(result, identityMock.resolvedPayload.entityNames)
    XCTAssertEqual(didResolverHelperSpy.getDidFromReceivedKid, kidMock)
    XCTAssertEqual(statementServiceSpy.fetchIdentityForReceivedSubjectDid, subjectDidMock)
  }

  func testGetEntityNames_didResolverThrows_returnsNil() async {
    didResolverHelperSpy.getDidFromThrowableError = TestingError.error

    let result = await service.getEntityNames(for: kidMock)

    XCTAssertNil(result)
  }

  func testGetEntityNames_statementServiceThrows_returnsNil() async {
    statementServiceSpy.fetchIdentityForThrowableError = TestingError.error

    let result = await service.getEntityNames(for: kidMock)

    XCTAssertNil(result)
  }

  // MARK: Private

  private let kidMock = "did:tdw:mock:identifier-reg.trust-infra.swiyu.admin.ch:example#key-id"
  private let subjectDidMock = "did:tdw:mock:identifier-reg.trust-infra.swiyu.admin.ch:example"
  private let vcSchemaIdMock = "vcSchemaId"
  private let vcSchemaTypeMock = VcSchemaTrustStatementType.issuance
  private let identityMock = IdentityTrustStatementV1JWT.Mock.validSample
  private let vcSchemaMock = VcSchemaTrustStatementJWT.Mock.validSample
  private let metadataJwsMock = CredentialIssuerMetadataJWT.Mock.sample

  private var statementServiceSpy: TrustStatementServiceProtocolSpy!
  private var didResolverHelperSpy: DidResolverHelperProtocolSpy!

  private var service: TrustInformationService!

  private func registerMocks() {
    statementServiceSpy = TrustStatementServiceProtocolSpy()
    didResolverHelperSpy = DidResolverHelperProtocolSpy()

    Container.shared.trustStatementService.register { self.statementServiceSpy }
    Container.shared.didResolverHelper.register { self.didResolverHelperSpy }
  }

  private func setupSuccessState() {
    statementServiceSpy.fetchIdentityForReturnValue = identityMock
    statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdReturnValue = vcSchemaMock
    didResolverHelperSpy.getDidFromReturnValue = subjectDidMock
  }
}
