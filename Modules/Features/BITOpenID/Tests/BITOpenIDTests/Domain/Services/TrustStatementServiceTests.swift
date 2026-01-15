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
    XCTAssertEqual(repositorySpy.fetchIdentityTrustStatementsFromForReceivedArguments?.url, trustRegistryURLMock)
    XCTAssertEqual(repositorySpy.fetchIdentityTrustStatementsFromForReceivedArguments?.subjectDid, subjectDidMock)

    XCTAssertEqual(identityValidatorSpy.validateForCallsCount, 1)
    XCTAssertEqual(identityValidatorSpy.validateForReceivedTrustStatement, identityTrustStatementMock)
    XCTAssertEqual(identityValidatorSpy.validateForReceivedSubject, subjectDidMock)
  }

  func testFetchIdentity_thirdTrustStatementIsValid_returnsThirdTrustStatement() async throws {
    repositorySpy.fetchIdentityTrustStatementsFromForReturnValue = [
      IdentityTrustStatementJWT.Mock.invalidVct,
      IdentityTrustStatementJWT.Mock.allFields,
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
      IdentityTrustStatementJWT.Mock.invalidVct,
      IdentityTrustStatementJWT.Mock.invalidVct,
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

  func testFetchIdentity_didIsNotTrusted_throwsValidationError() async throws {
    Container.shared.trustRegistryTrustedDids.register { ["example.com": ["other"]] }
    service = TrustStatementService()

    do {
      _ = try await service.fetchIdentity(for: subjectDidMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TrustStatementServiceError, .validationFailed)
    }
  }

  func testFetchIdentity_noTrustedDidForURL_throwsValidationError() async throws {
    Container.shared.trustRegistryTrustedDids.register { ["other": ["issuer"]] }
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
    XCTAssertEqual(repositorySpy.fetchVcSchemaTrustStatementsFromForTypeVcSchemaIdReceivedArguments?.url, trustRegistryURLMock)
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
      VcSchemaTrustStatementJWT.Mock.invalidVct,
      VcSchemaTrustStatementJWT.Mock.validOtherSample,
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
      VcSchemaTrustStatementJWT.Mock.invalidVct,
      VcSchemaTrustStatementJWT.Mock.invalidVct,
    ]

    let trustStatement = try await service.fetchVcSchema(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertNil(trustStatement)
  }

  func testFetchVcSchema_verificationTrustStatementWithOtherVct_returnsNil() async throws {
    setupVcSchemaTrustStatement()
    repositorySpy.fetchVcSchemaTrustStatementsFromForTypeVcSchemaIdReturnValue = [
      VcSchemaTrustStatementJWT.Mock.invalidVct,
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

  func testFetchVcSchema_didIsNotTrusted_returnsNil() async throws {
    setupVcSchemaTrustStatement()
    Container.shared.trustRegistryTrustedDids.register { ["example.com": ["other"]] }
    service = TrustStatementService()

    let trustStatement = try await service.fetchVcSchema(for: subjectDidMock, type: vcSchemaTypeMock, vcSchemaId: vcSchemaIdMock)

    XCTAssertNil(trustStatement)
  }

  func testFetchVcSchema_noTrustedDidForURL_returnsNil() async throws {
    setupVcSchemaTrustStatement()
    Container.shared.trustRegistryTrustedDids.register { ["other": ["issuer"]] }
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

  private let trustRegistryURLMock = URL(string: "https://example.com")
  private let trustedDids = ["example.com": ["did:tdw:another-example", "issuer"]]
  private var subjectDidMock = "subjectDid"
  private var vcSchemaTypeMock = VcSchemaTrustStatementType.issuance
  private var vcSchemaIdMock = "vcSchemaId"
  private let identityTrustStatementMock = IdentityTrustStatementJWT.Mock.validSample
  private let vcSchemaTrustStatementMock = VcSchemaTrustStatementJWT.Mock.validSample

  private var mapperSpy: TrustRegistryUrlMapperProtocolSpy!
  private var repositorySpy: TrustStatementRepositoryProtocolSpy!
  private var identityValidatorSpy: TrustStatementValidatorProtocolSpy<IdentityTrustStatementJWT>!
  private var vcSchemaValidatorSpy: TrustStatementValidatorProtocolSpy<VcSchemaTrustStatementJWT>!

  private var service: TrustStatementService!

  private func registerMocks() {
    mapperSpy = TrustRegistryUrlMapperProtocolSpy()
    repositorySpy = TrustStatementRepositoryProtocolSpy()
    identityValidatorSpy = TrustStatementValidatorProtocolSpy()

    Container.shared.trustRegistryUrlMapper.register { self.mapperSpy }
    Container.shared.trustStatementRepository.register { self.repositorySpy }
    Container.shared.trustStatementValidator.register { self.identityValidatorSpy }
    Container.shared.trustRegistryTrustedDids.register { self.trustedDids }
  }

  private func success() {
    mapperSpy.mapDidReturnValue = trustRegistryURLMock
    repositorySpy.fetchIdentityTrustStatementsFromForReturnValue = [identityTrustStatementMock]
    identityValidatorSpy.validateForReturnValue = true
  }

  private func setupVcSchemaTrustStatement() {
    vcSchemaValidatorSpy = TrustStatementValidatorProtocolSpy()
    Container.shared.trustStatementValidator.register { self.vcSchemaValidatorSpy }

    service = TrustStatementService()

    repositorySpy.fetchVcSchemaTrustStatementsFromForTypeVcSchemaIdReturnValue = [vcSchemaTrustStatementMock]
    vcSchemaValidatorSpy.validateForReturnValue = true
  }
}
