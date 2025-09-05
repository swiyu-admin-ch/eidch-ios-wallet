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

  func testFetch_oneValidTrustStatement_returnsTrustStatement() async throws {
    let trustStatement = try await service.fetch(for: subjectMock)

    XCTAssertEqual(trustStatement, trustStatementMock)
  }

  func testFetch_oneValidTrustStatement_argumentsPassed() async throws {
    _ = try await service.fetch(for: subjectMock)

    XCTAssertEqual(trustRegistryRepositorySpy.getTrustRegistryDomainForCallsCount, 1)
    XCTAssertEqual(trustRegistryRepositorySpy.getTrustRegistryDomainForReceivedBaseRegistryDomain, Self.subjectDomain)
    XCTAssertEqual(openIDRepositorySpy.fetchTrustStatementsFromForCallsCount, 1)
    XCTAssertEqual(openIDRepositorySpy.fetchTrustStatementsFromForReceivedArguments?.url.absoluteString, "https://\(Self.registryDomain)")
    XCTAssertEqual(openIDRepositorySpy.fetchTrustStatementsFromForReceivedArguments?.subjectDid, subjectMock)
    XCTAssertEqual(trustStatementValidatorSpy.validateForCallsCount, 1)
    XCTAssertEqual(trustStatementValidatorSpy.validateForReceivedArguments?.trustStatement, trustStatementMock)
    XCTAssertEqual(trustStatementValidatorSpy.validateForReceivedArguments?.subject, subjectMock)
  }

  func testFetch_thirdTrustStatementIsValid_returnsThirdTrustStatement() async throws {
    openIDRepositorySpy.fetchTrustStatementsFromForReturnValue = [
      TrustStatementPayload.Mock.allFields,
      TrustStatementPayload.Mock.allFields,
      trustStatementMock,
    ]
    var count = 0
    trustStatementValidatorSpy.validateForClosure = { _, _ in
      if count < 2 {
        count += 1
        return false
      }
      return true
    }

    let trustStatement = try await service.fetch(for: subjectMock)

    XCTAssertEqual(trustStatementValidatorSpy.validateForCallsCount, 3)
    XCTAssertEqual(trustStatement, trustStatementMock)
  }

  func testFetch_multipleTrustStatementsAreValid_returnsNil() async throws {
    openIDRepositorySpy.fetchTrustStatementsFromForReturnValue = [
      trustStatementMock,
      trustStatementMock,
    ]

    let trustStatement = try await service.fetch(for: subjectMock)

    XCTAssertNil(trustStatement)
  }

  func testFetch_noTrustStatements_returnsNil() async throws {
    openIDRepositorySpy.fetchTrustStatementsFromForReturnValue = []

    let trustStatement = try await service.fetch(for: subjectMock)

    XCTAssertNil(trustStatement)
  }

  func testFetch_invalidTrustStatement_returnsNil() async throws {
    trustStatementValidatorSpy.validateForReturnValue = false

    let trustStatement = try await service.fetch(for: subjectMock)

    XCTAssertNil(trustStatement)
  }

  func testFetch_notMatchingBaseRegistryDomain_throwsError() async throws {
    Container.shared.baseRegistryDomainPattern.register { #"^not_matching:([^:]+)$"# }
    service = TrustStatementService()

    do {
      _ = try await service.fetch(for: subjectMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TrustStatementServiceError, .cannotParseTrustRegistryDomain)
    }
  }

  func testFetch_trustRegistryRepositoryReturnsNil_throwsError() async throws {
    trustRegistryRepositorySpy.getTrustRegistryDomainForReturnValue = nil

    do {
      _ = try await service.fetch(for: subjectMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TrustStatementServiceError, .cannotParseTrustRegistryDomain)
    }
  }

  func testFetch_openIDRepositoryThrows_throwsError() async throws {
    openIDRepositorySpy.fetchTrustStatementsFromForThrowableError = TestingError.error

    do {
      _ = try await service.fetch(for: subjectMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private static let registryDomain = "registry.ch"
  private static let subjectDomain = "subject.ch"

  private var subjectMock = "did:tdw:\(subjectDomain)"
  private let trustStatementMock = TrustStatementPayload.Mock.validSample

  private var trustRegistryRepositorySpy: TrustRegistryRepositoryProtocolSpy!
  private var openIDRepositorySpy: OpenIDRepositoryProtocolSpy!
  private var trustStatementValidatorSpy: TrustStatementValidatorProtocolSpy!

  private var service: TrustStatementService!

  private func registerMocks() {
    trustRegistryRepositorySpy = TrustRegistryRepositoryProtocolSpy()
    openIDRepositorySpy = OpenIDRepositoryProtocolSpy()
    trustStatementValidatorSpy = TrustStatementValidatorProtocolSpy()

    Container.shared.trustRegistryRepository.register { self.trustRegistryRepositorySpy }
    Container.shared.openIDRepository.register { self.openIDRepositorySpy }
    Container.shared.trustStatementValidator.register { self.trustStatementValidatorSpy }
    Container.shared.baseRegistryDomainPattern.register { #"^did:tdw:([^:]+)$"# }
  }

  private func success() {
    trustRegistryRepositorySpy.getTrustRegistryDomainForReturnValue = Self.registryDomain
    openIDRepositorySpy.fetchTrustStatementsFromForReturnValue = [trustStatementMock]
    trustStatementValidatorSpy.validateForReturnValue = true
  }

  // swiftlint:enable all
}
