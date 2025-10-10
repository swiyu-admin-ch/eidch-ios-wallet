import BITSdJWT
import Factory
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITAnyCredentialFormatMocks
@testable import BITOpenID
@testable import BITTestingCore

// swiftlint:disable force_unwrapping implicitly_unwrapped_optional

final class TrustStatementServiceTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    service = TrustStatementService()
    success()
  }

  // MARK: fetchMetadata

  func testFetchMetadata_oneValidTrustStatement_returnsTrustStatement() async throws {
    setupMetadataTrustStatement()

    let trustStatement = try await service.fetchMetadata(for: subjectDidMock)

    XCTAssertEqual(trustStatement, metadataTrustStatementMock)
  }

  func testFetchMetadata_oneValidTrustStatement_argumentsPassed() async throws {
    setupMetadataTrustStatement()

    _ = try await service.fetchMetadata(for: subjectDidMock)

    XCTAssertEqual(mapperSpy.mapDidCallsCount, 1)
    XCTAssertEqual(mapperSpy.mapDidReceivedDid, subjectDidMock)

    XCTAssertEqual(repositorySpy.fetchMetadataTrustStatementsFromForCallsCount, 1)
    XCTAssertEqual(repositorySpy.fetchMetadataTrustStatementsFromForReceivedArguments?.url, trustStatementUrlMock)
    XCTAssertEqual(repositorySpy.fetchMetadataTrustStatementsFromForReceivedArguments?.subjectDid, subjectDidMock)

    XCTAssertEqual(metadataValidatorSpy.validateForCallsCount, 1)
    XCTAssertEqual(metadataValidatorSpy.validateForReceivedTrustStatement, metadataTrustStatementMock)
    XCTAssertEqual(metadataValidatorSpy.validateForReceivedSubject, subjectDidMock)
  }

  func testFetchMetadata_thirdTrustStatementIsValid_returnsThirdTrustStatement() async throws {
    setupMetadataTrustStatement()
    repositorySpy.fetchMetadataTrustStatementsFromForReturnValue = [
      MetadataTrustStatementPayload.Mock.invalidVct,
      MetadataTrustStatementPayload.Mock.allFields,
      metadataTrustStatementMock,
    ]
    var count = 0
    metadataValidatorSpy.validateForClosure = { _, _ in
      if count < 1 {
        count += 1
        return false
      }
      return true
    }

    let trustStatement = try await service.fetchMetadata(for: subjectDidMock)

    XCTAssertEqual(metadataValidatorSpy.validateForCallsCount, 2)
    XCTAssertEqual(trustStatement, metadataTrustStatementMock)
  }

  func testFetchMetadata_multipleTrustStatementsAreValid_throwsValidationError() async throws {
    setupMetadataTrustStatement()
    repositorySpy.fetchMetadataTrustStatementsFromForReturnValue = [
      metadataTrustStatementMock,
      metadataTrustStatementMock,
    ]

    do {
      _ = try await service.fetchMetadata(for: subjectDidMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TrustStatementServiceError, .validationFailed)
    }
  }

  func testFetchMetadata_multipleTrustStatementsWithOtherVct_throwsValidationError() async throws {
    setupMetadataTrustStatement()
    repositorySpy.fetchMetadataTrustStatementsFromForReturnValue = [
      MetadataTrustStatementPayload.Mock.invalidVct,
      MetadataTrustStatementPayload.Mock.invalidVct,
    ]

    do {
      _ = try await service.fetchMetadata(for: subjectDidMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TrustStatementServiceError, .validationFailed)
    }
  }

  func testFetchMetadata_noTrustStatements_throwsValidationError() async throws {
    setupMetadataTrustStatement()
    repositorySpy.fetchMetadataTrustStatementsFromForReturnValue = []

    do {
      _ = try await service.fetchMetadata(for: subjectDidMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TrustStatementServiceError, .validationFailed)
    }
  }

  func testFetchMetadata_noTrustStatementFromTrustedDid_throwsValidationError() async throws {
    setupMetadataTrustStatement()
    Container.shared.trustRegistryTrustedDids.register { ["other"] }
    service = TrustStatementService()

    do {
      _ = try await service.fetchMetadata(for: subjectDidMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TrustStatementServiceError, .validationFailed)
    }
  }

  func testFetchMetadata_invalidTrustStatement_throwsValidationError() async throws {
    setupMetadataTrustStatement()
    metadataValidatorSpy.validateForReturnValue = false

    do {
      _ = try await service.fetchMetadata(for: subjectDidMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TrustStatementServiceError, .validationFailed)
    }
  }

  func testFetchMetadata_trustStatementRepositoryThrows_throwsError() async throws {
    setupMetadataTrustStatement()
    repositorySpy.fetchMetadataTrustStatementsFromForThrowableError = TestingError.error

    do {
      _ = try await service.fetchMetadata(for: subjectDidMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: fetchIdentity

  func testFetchIdentity_oneValidTrustStatement_returnsTrustStatement() async throws {
    let trustStatement = try await service.fetchIdentity(for: subjectDidMock)

    XCTAssertEqual(trustStatement, identityTrustStatementMock)
  }

  func testFetchIdentity_oneValidTrustStatement_argumentsPassed() async throws {
    _ = try await service.fetchIdentity(for: subjectDidMock)

    XCTAssertEqual(mapperSpy.mapDidCallsCount, 1)
    XCTAssertEqual(mapperSpy.mapDidReceivedDid, subjectDidMock)

    XCTAssertEqual(repositorySpy.fetchIdentityTrustStatementsFromForCallsCount, 1)
    XCTAssertEqual(repositorySpy.fetchIdentityTrustStatementsFromForReceivedArguments?.url, trustStatementUrlMock)
    XCTAssertEqual(repositorySpy.fetchIdentityTrustStatementsFromForReceivedArguments?.subjectDid, subjectDidMock)

    XCTAssertEqual(identityValidatorSpy.validateForCallsCount, 1)
    XCTAssertEqual(identityValidatorSpy.validateForReceivedTrustStatement, identityTrustStatementMock)
    XCTAssertEqual(identityValidatorSpy.validateForReceivedSubject, subjectDidMock)
  }

  func testFetchIdentity_thirdTrustStatementIsValid_returnsThirdTrustStatement() async throws {
    repositorySpy.fetchIdentityTrustStatementsFromForReturnValue = [
      IdentityTrustStatementPayload.Mock.invalidVct,
      IdentityTrustStatementPayload.Mock.allFields,
      identityTrustStatementMock,
    ]
    var count = 0
    identityValidatorSpy.validateForClosure = { _, _ in
      if count < 1 {
        count += 1
        return false
      }
      return true
    }

    let trustStatement = try await service.fetchIdentity(for: subjectDidMock)

    XCTAssertEqual(identityValidatorSpy.validateForCallsCount, 2)
    XCTAssertEqual(trustStatement, identityTrustStatementMock)
  }

  func testFetchIdentity_multipleTrustStatementsAreValid_throwsValidationError() async throws {
    repositorySpy.fetchIdentityTrustStatementsFromForReturnValue = [
      identityTrustStatementMock,
      identityTrustStatementMock,
    ]

    do {
      _ = try await service.fetchIdentity(for: subjectDidMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TrustStatementServiceError, .validationFailed)
    }
  }

  func testFetchIdentity_multipleTrustStatementsWithOtherVct_throwsValidationError() async throws {
    repositorySpy.fetchIdentityTrustStatementsFromForReturnValue = [
      IdentityTrustStatementPayload.Mock.invalidVct,
      IdentityTrustStatementPayload.Mock.invalidVct,
    ]

    do {
      _ = try await service.fetchIdentity(for: subjectDidMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TrustStatementServiceError, .validationFailed)
    }
  }

  func testFetchIdentity_noTrustStatements_throwsValidationError() async throws {
    repositorySpy.fetchIdentityTrustStatementsFromForReturnValue = []

    do {
      _ = try await service.fetchIdentity(for: subjectDidMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TrustStatementServiceError, .validationFailed)
    }
  }

  func testFetchIdentity_noTrustStatementFromTrustedDid_throwsValidationError() async throws {
    Container.shared.trustRegistryTrustedDids.register { ["other"] }
    service = TrustStatementService()

    do {
      _ = try await service.fetchIdentity(for: subjectDidMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TrustStatementServiceError, .validationFailed)
    }
  }

  func testFetchIdentity_invalidTrustStatement_throwsValidationError() async throws {
    identityValidatorSpy.validateForReturnValue = false

    do {
      _ = try await service.fetchIdentity(for: subjectDidMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TrustStatementServiceError, .validationFailed)
    }
  }

  func testFetchIdentity_trustStatementRepositoryThrows_throwsError() async throws {
    repositorySpy.fetchIdentityTrustStatementsFromForThrowableError = TestingError.error

    do {
      _ = try await service.fetchIdentity(for: subjectDidMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: fetchVcSchema

  func testFetchVcSchema_oneValidTrustStatement_returnsTrustStatement() async throws {
    setupVcSchemaTrustStatement()

    let trustStatement = try await service.fetchVcSchema(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertEqual(trustStatement, vcSchemaTrustStatementMock)
  }

  func testFetchVcSchema_oneValidTrustStatement_argumentsPassed() async throws {
    setupVcSchemaTrustStatement()

    _ = try await service.fetchVcSchema(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertEqual(mapperSpy.mapDidCallsCount, 1)
    XCTAssertEqual(mapperSpy.mapDidReceivedDid, subjectDidMock)

    XCTAssertEqual(repositorySpy.fetchVcSchemaTrustStatementsFromForTypeVcSchemaIdCallsCount, 1)
    XCTAssertEqual(repositorySpy.fetchVcSchemaTrustStatementsFromForTypeVcSchemaIdReceivedArguments?.url, trustStatementUrlMock)
    XCTAssertEqual(repositorySpy.fetchVcSchemaTrustStatementsFromForTypeVcSchemaIdReceivedArguments?.subjectDid, subjectDidMock)
    XCTAssertEqual(repositorySpy.fetchVcSchemaTrustStatementsFromForTypeVcSchemaIdReceivedArguments?.type, vcSchemaTypeMock)
    XCTAssertEqual(repositorySpy.fetchVcSchemaTrustStatementsFromForTypeVcSchemaIdReceivedArguments?.vcSchemaId, vcSchemaIdMock)

    XCTAssertEqual(vcSchemaValidatorSpy.validateForCallsCount, 1)
    XCTAssertEqual(vcSchemaValidatorSpy.validateForReceivedTrustStatement, vcSchemaTrustStatementMock)
    XCTAssertEqual(vcSchemaValidatorSpy.validateForReceivedSubject, subjectDidMock)
  }

  func testFetchVcSchema_thirdTrustStatementIsValid_returnsThirdTrustStatement() async throws {
    setupVcSchemaTrustStatement()
    repositorySpy.fetchVcSchemaTrustStatementsFromForTypeVcSchemaIdReturnValue = [
      VcSchemaTrustStatementPayload.Mock.invalidVct,
      VcSchemaTrustStatementPayload.Mock.validOtherSample,
      vcSchemaTrustStatementMock,
    ]
    var count = 0
    vcSchemaValidatorSpy.validateForClosure = { _, _ in
      if count < 1 {
        count += 1
        return false
      }
      return true
    }

    let trustStatement = try await service.fetchVcSchema(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertEqual(vcSchemaValidatorSpy.validateForCallsCount, 2)
    XCTAssertEqual(trustStatement, vcSchemaTrustStatementMock)
  }

  func testFetchVcSchema_multipleTrustStatementsAreValid_throwsValidationError() async throws {
    setupVcSchemaTrustStatement()
    repositorySpy.fetchVcSchemaTrustStatementsFromForTypeVcSchemaIdReturnValue = [
      vcSchemaTrustStatementMock,
      vcSchemaTrustStatementMock,
    ]

    do {
      _ = try await service.fetchVcSchema(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TrustStatementServiceError, .validationFailed)
    }
  }

  func testFetchVcSchema_multipleTrustStatementsWithOtherVct_returnsNil() async throws {
    setupVcSchemaTrustStatement()
    repositorySpy.fetchVcSchemaTrustStatementsFromForTypeVcSchemaIdReturnValue = [
      VcSchemaTrustStatementPayload.Mock.invalidVct,
      VcSchemaTrustStatementPayload.Mock.invalidVct,
    ]

    let trustStatement = try await service.fetchVcSchema(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertNil(trustStatement)
  }

  func testFetchVcSchema_verificationTrustStatementWithOtherVct_returnsNil() async throws {
    setupVcSchemaTrustStatement()
    repositorySpy.fetchVcSchemaTrustStatementsFromForTypeVcSchemaIdReturnValue = [
      VcSchemaTrustStatementPayload.Mock.invalidVct,
    ]

    let trustStatement = try await service.fetchVcSchema(for: subjectDidMock, type: .verification, vcSchemaId: vcSchemaIdMock)

    XCTAssertNil(trustStatement)
  }

  func testFetchVcSchema_noTrustStatements_returnsNil() async throws {
    setupVcSchemaTrustStatement()
    repositorySpy.fetchVcSchemaTrustStatementsFromForTypeVcSchemaIdReturnValue = []

    let trustStatement = try await service.fetchVcSchema(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertNil(trustStatement)
  }

  func testFetchVcSchema_noTrustStatementFromTrustedDid_returnsNil() async throws {
    setupVcSchemaTrustStatement()
    Container.shared.trustRegistryTrustedDids.register { ["other"] }
    service = TrustStatementService()

    let trustStatement = try await service.fetchVcSchema(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertNil(trustStatement)
  }

  func testFetchVcSchema_invalidTrustStatement_throwsValidationError() async throws {
    setupVcSchemaTrustStatement()
    vcSchemaValidatorSpy.validateForReturnValue = false

    do {
      _ = try await service.fetchVcSchema(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TrustStatementServiceError, .validationFailed)
    }
  }

  func testFetchVcSchema_invalidVcSchemaId_throwsValidationError() async throws {
    setupVcSchemaTrustStatement()
    do {
      _ = try await service.fetchVcSchema(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: "invalid")
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TrustStatementServiceError, .validationFailed)
    }
  }

  func testFetchVcSchema_trustStatementRepositoryThrows_throwsError() async throws {
    setupVcSchemaTrustStatement()
    repositorySpy.fetchVcSchemaTrustStatementsFromForTypeVcSchemaIdThrowableError = TestingError.error

    do {
      _ = try await service.fetchVcSchema(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let trustStatementUrlMock = URL(string: "https://example.com")
  private let trustedDids: [String] = ["did:tdw:another-example", "issuer"]
  private var subjectDidMock = "subjectDid"
  private var vcSchemaTypeMock = VcSchemaTrustStatementType.issuance
  private var vcSchemaIdMock = "vcSchemaId"
  private let metadataTrustStatementMock = MetadataTrustStatementPayload.Mock.validSample
  private let identityTrustStatementMock = IdentityTrustStatementPayload.Mock.validSample
  private let vcSchemaTrustStatementMock = VcSchemaTrustStatementPayload.Mock.validSample

  private var mapperSpy: TrustStatementUrlMapperProtocolSpy!
  private var repositorySpy: TrustStatementRepositoryProtocolSpy!
  private var metadataValidatorSpy: TrustStatementValidatorProtocolSpy<MetadataTrustStatementPayload>!
  private var identityValidatorSpy: TrustStatementValidatorProtocolSpy<IdentityTrustStatementPayload>!
  private var vcSchemaValidatorSpy: TrustStatementValidatorProtocolSpy<VcSchemaTrustStatementPayload>!

  private var service: TrustStatementService!

  private func registerMocks() {
    mapperSpy = TrustStatementUrlMapperProtocolSpy()
    repositorySpy = TrustStatementRepositoryProtocolSpy()
    identityValidatorSpy = TrustStatementValidatorProtocolSpy()

    Container.shared.trustStatementUrlMapper.register { self.mapperSpy }
    Container.shared.trustStatementRepository.register { self.repositorySpy }
    Container.shared.trustStatementValidator.register { self.identityValidatorSpy }
    Container.shared.trustRegistryTrustedDids.register { self.trustedDids }
  }

  private func success() {
    mapperSpy.mapDidReturnValue = trustStatementUrlMock
    repositorySpy.fetchIdentityTrustStatementsFromForReturnValue = [identityTrustStatementMock]
    identityValidatorSpy.validateForReturnValue = true
  }

  private func setupMetadataTrustStatement() {
    metadataValidatorSpy = TrustStatementValidatorProtocolSpy()
    Container.shared.trustStatementValidator.register { self.metadataValidatorSpy }

    service = TrustStatementService()

    repositorySpy.fetchMetadataTrustStatementsFromForReturnValue = [metadataTrustStatementMock]
    metadataValidatorSpy.validateForReturnValue = true
  }

  private func setupVcSchemaTrustStatement() {
    vcSchemaValidatorSpy = TrustStatementValidatorProtocolSpy()
    Container.shared.trustStatementValidator.register { self.vcSchemaValidatorSpy }

    service = TrustStatementService()

    repositorySpy.fetchVcSchemaTrustStatementsFromForTypeVcSchemaIdReturnValue = [vcSchemaTrustStatementMock]
    vcSchemaValidatorSpy.validateForReturnValue = true
  }
}
