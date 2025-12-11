import Factory
import XCTest
@testable import BITCredential
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

  // MARK: - testFetch metadata

  func testFetch_validMetadataAndVcSchemaStatement_returnsTrusted() async throws {
    Container.shared.isIdentityTrustStatementEnabled.register { false }
    service = TrustInformationService()

    let result = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    assertTrustStatementPayload(result.identity, metadataMock.resolvedPayload)
    XCTAssertEqual(result.vcSchema, .trusted)
  }

  func testFetch_validMetadataAndVcSchemaStatement_argumentsPassed() async throws {
    Container.shared.isIdentityTrustStatementEnabled.register { false }
    service = TrustInformationService()

    _ = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertEqual(statementServiceSpy.fetchMetadataForCallsCount, 1)
    XCTAssertEqual(statementServiceSpy.fetchMetadataForReceivedSubjectDid, subjectDidMock)

    XCTAssertEqual(statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdCallsCount, 1)
    XCTAssertEqual(statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdReceivedArguments?.subjectDid, subjectDidMock)
    XCTAssertEqual(statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdReceivedArguments?.type, vcSchemaTypeMock)
    XCTAssertEqual(statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdReceivedArguments?.vcSchemaId, vcSchemaIdMock)
  }

  func testFetch_validMetadataAndNoVcSchemaId_returnsIdentityTrusted() async throws {
    Container.shared.isIdentityTrustStatementEnabled.register { false }
    service = TrustInformationService()

    let result = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: nil)

    assertTrustStatementPayload(result.identity, metadataMock.resolvedPayload)
    XCTAssertEqual(result.vcSchema, .notProtected)
  }

  func testFetch_validMetadataAndNoVcSchemaId_argumentsPassed() async throws {
    Container.shared.isIdentityTrustStatementEnabled.register { false }
    service = TrustInformationService()

    _ = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: nil)

    XCTAssertEqual(statementServiceSpy.fetchMetadataForCallsCount, 1)
    XCTAssertEqual(statementServiceSpy.fetchMetadataForReceivedSubjectDid, subjectDidMock)

    XCTAssertEqual(statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdCallsCount, 0)
  }

  func testFetch_metadataUnknownSubjectDid_returnsUnknown() async throws {
    Container.shared.isIdentityTrustStatementEnabled.register { false }
    service = TrustInformationService()

    let result = await service.fetch(for: "unknown", type: vcSchemaTypeMock, vcSchemaId: nil)

    XCTAssertEqual(result.identity, .unknown)
    XCTAssertEqual(result.vcSchema, .notProtected)
  }

  func testFetch_metadataUnknownSubjectDid_argumentsPassed() async throws {
    Container.shared.isIdentityTrustStatementEnabled.register { false }
    service = TrustInformationService()

    _ = await service.fetch(for: "unknown", type: vcSchemaTypeMock, vcSchemaId: nil)

    XCTAssertEqual(statementServiceSpy.fetchMetadataForCallsCount, 0)
    XCTAssertEqual(statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdCallsCount, 0)
  }

  func testFetch_metadataFetchVcSchemaReturnsNil_returnsNotProtectedVcSchema() async throws {
    Container.shared.isIdentityTrustStatementEnabled.register { false }
    service = TrustInformationService()
    statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdReturnValue = nil

    let result = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    assertTrustStatementPayload(result.identity, metadataMock.resolvedPayload)
    XCTAssertEqual(result.vcSchema, .notProtected)
  }

  func testFetch_fetchMetadataThrowsError_returnsUntrustedIdentity() async throws {
    Container.shared.isIdentityTrustStatementEnabled.register { false }
    service = TrustInformationService()
    statementServiceSpy.fetchMetadataForThrowableError = TestingError.error

    let result = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertEqual(result.identity, .untrusted)
    XCTAssertEqual(result.vcSchema, .trusted)
  }

  func testFetch_metadataFetchVcSchemaThrowsValidationError_returnsUntrustedVcSchema() async throws {
    Container.shared.isIdentityTrustStatementEnabled.register { false }
    service = TrustInformationService()
    statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdThrowableError = TrustStatementServiceError.validationFailed

    let result = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    assertTrustStatementPayload(result.identity, metadataMock.resolvedPayload)
    XCTAssertEqual(result.vcSchema, .untrusted)
  }

  func testFetch_metadataFetchVcSchemaThrowsError_returnsNotProtectedVcSchema() async throws {
    Container.shared.isIdentityTrustStatementEnabled.register { false }
    service = TrustInformationService()
    statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdThrowableError = TestingError.error

    let result = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    assertTrustStatementPayload(result.identity, metadataMock.resolvedPayload)
    XCTAssertEqual(result.vcSchema, .notProtected)
  }

  // MARK: - testFetch identity

  func testFetch_validIdentityAndIssuanceStatement_returnsTrusted() async throws {
    let result = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    assertTrustStatementPayload(result.identity, identityMock.resolvedPayload)
    XCTAssertEqual(result.vcSchema, .trusted)
  }

  func testFetch_validIdentityAndIssuanceStatement_argumentsPassed() async throws {
    _ = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertEqual(statementServiceSpy.fetchIdentityForCallsCount, 1)
    XCTAssertEqual(statementServiceSpy.fetchIdentityForReceivedSubjectDid, subjectDidMock)

    XCTAssertEqual(statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdCallsCount, 1)
    XCTAssertEqual(statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdReceivedArguments?.subjectDid, subjectDidMock)
    XCTAssertEqual(statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdReceivedArguments?.type, vcSchemaTypeMock)
    XCTAssertEqual(statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdReceivedArguments?.vcSchemaId, vcSchemaIdMock)
  }

  func testFetch_validIdentityAndNoVcSchemaId_returnsIdentityTrusted() async throws {
    let result = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: nil)

    assertTrustStatementPayload(result.identity, identityMock.resolvedPayload)
    XCTAssertEqual(result.vcSchema, .notProtected)
  }

  func testFetch_validIdentityAndNoVcSchemaId_argumentsPassed() async throws {
    _ = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: nil)

    XCTAssertEqual(statementServiceSpy.fetchIdentityForCallsCount, 1)
    XCTAssertEqual(statementServiceSpy.fetchIdentityForReceivedSubjectDid, subjectDidMock)

    XCTAssertEqual(statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdCallsCount, 0)
  }

  func testFetch_unknownSubjectDid_returnsUnknown() async throws {
    let result = await service.fetch(for: "unknown", type: vcSchemaTypeMock, vcSchemaId: nil)

    XCTAssertEqual(result.identity, .unknown)
    XCTAssertEqual(result.vcSchema, .notProtected)
  }

  func testFetch_unknownSubjectDid_argumentsPassed() async throws {
    _ = await service.fetch(for: "unknown", type: vcSchemaTypeMock, vcSchemaId: nil)

    XCTAssertEqual(statementServiceSpy.fetchIdentityForCallsCount, 0)
    XCTAssertEqual(statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdCallsCount, 0)
  }

  func testFetch_fetchVcSchemaReturnsNil_returnsNotProtectedVcSchema() async throws {
    statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdReturnValue = nil

    let result = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    assertTrustStatementPayload(result.identity, identityMock.resolvedPayload)
    XCTAssertEqual(result.vcSchema, .notProtected)
  }

  func testFetch_fetchIdentityThrowsError_returnsUntrustedIdentity() async throws {
    statementServiceSpy.fetchIdentityForThrowableError = TestingError.error

    let result = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertEqual(result.identity, .untrusted)
    XCTAssertEqual(result.vcSchema, .trusted)
  }

  func testFetch_fetchVcSchemaThrowsValidationError_returnsUntrustedVcSchema() async throws {
    statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdThrowableError = TrustStatementServiceError.validationFailed

    let result = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    assertTrustStatementPayload(result.identity, identityMock.resolvedPayload)
    XCTAssertEqual(result.vcSchema, .untrusted)
  }

  func testFetch_fetchVcSchemaThrowsError_returnsNotProtectedVcSchema() async throws {
    statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdThrowableError = TestingError.error

    let result = await service.fetch(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    assertTrustStatementPayload(result.identity, identityMock.resolvedPayload)
    XCTAssertEqual(result.vcSchema, .notProtected)
  }

  // MARK: Private

  private let subjectDidMock = "did:tdw:mock:identifier-reg.trust-infra.swiyu.admin.ch:example"
  private let vcSchemaIdMock = "vcSchemaId"
  private let vcSchemaTypeMock = VcSchemaTrustStatementType.issuance
  private let metadataMock = MetadataTrustStatementPayload.Mock.validSample
  private let identityMock = IdentityTrustStatementPayload.Mock.validSample
  private let vcSchemaMock = VcSchemaTrustStatementPayload.Mock.validSample

  private var statementServiceSpy: TrustStatementServiceProtocolSpy!

  private var service: TrustInformationService!

  private func registerMocks() {
    statementServiceSpy = TrustStatementServiceProtocolSpy()

    Container.shared.trustStatementService.register { self.statementServiceSpy }
    Container.shared.isIdentityTrustStatementEnabled.register { true }
  }

  private func setupSuccessState() {
    statementServiceSpy.fetchMetadataForReturnValue = metadataMock
    statementServiceSpy.fetchIdentityForReturnValue = identityMock
    statementServiceSpy.fetchVcSchemaForTypeVcSchemaIdReturnValue = vcSchemaMock
  }

  private func assertTrustStatementPayload<T>(_ identityTrust: IdentityTrust, _ expected: T) where T: LocalizedTrustStatement & Equatable {
    if case .trusted(let trustStatement) = identityTrust {
      XCTAssertEqual(trustStatement as? T, expected)
    } else {
      XCTFail("Should have been trusted")
    }
  }
}
