import BITSdJWT
import Factory
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITAnyCredentialFormatMocks
@testable import BITOpenID
@testable import BITTestingCore

// swiftlint:disable force_unwrapping implicitly_unwrapped_optional

final class FetchTrustStatementUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    Container.shared.trustRegistryRepository.register { self.trustRegistryRepositorySpy }
    Container.shared.openIDRepository.register { self.openIDRepositorySpy }
    Container.shared.validateTrustStatementUseCase.register { self.validateTrustStatementUseCaseSpy }
    Container.shared.baseRegistryDomainPattern.register { #"^did:tdw:([^:]+)$"# }

    useCase = FetchTrustStatementUseCase()

    success()
  }

  func testExecute_success_returnsTrustStatement() async throws {
    let trustStatement = try await useCase.execute(issuer: issuerMock)

    XCTAssertEqual(trustStatement, trustStatementMock)
  }

  func testExecute_validAnyCredential_argumentsPassed() async throws {
    let trustStatement = try await useCase.execute(issuer: issuerMock)

    XCTAssertEqual(trustRegistryRepositorySpy.getTrustRegistryDomainForReceivedBaseRegistryDomain, Self.issuerDomain)
    XCTAssertEqual(openIDRepositorySpy.fetchTrustStatementsFromIssuerDidReceivedArguments?.url.absoluteString, "https://\(Self.registryDomain)")
    XCTAssertEqual(openIDRepositorySpy.fetchTrustStatementsFromIssuerDidReceivedArguments?.issuerDid, issuerMock)
    XCTAssertEqual(validateTrustStatementUseCaseSpy.executeReceivedTrustStatement, trustStatement)
  }

  func testExecute_thirdTrustStatementIsValid_returnsThirdTrustStatement() async throws {
    openIDRepositorySpy.fetchTrustStatementsFromIssuerDidReturnValue = [
      unsupportedTrustStatement,
      TrustStatementPayload.Mock.validSampleItalian,
      trustStatementMock,
    ]
    var count = 0
    validateTrustStatementUseCaseSpy.executeClosure = { _ in
      if count == 0 {
        count += 1
        return false
      } else {
        return true
      }
    }

    let trustStatement = try await useCase.execute(issuer: issuerMock)

    XCTAssertEqual(trustStatement, trustStatementMock)
  }

  func testExecute_notMatchingBaseRegistryDomain_throwsError() async throws {
    Container.shared.baseRegistryDomainPattern.register { #"^not_matching:([^:]+)$"# }
    useCase = FetchTrustStatementUseCase()

    do {
      _ = try await useCase.execute(issuer: issuerMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? FetchTrustStatementUseCaseError, .cannotParseTrustRegistryDomain)
    }
  }

  func testExecute_trustRegistryRepositoryReturnsNil_throwsError() async throws {
    trustRegistryRepositorySpy.getTrustRegistryDomainForReturnValue = nil

    do {
      _ = try await useCase.execute(issuer: issuerMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? FetchTrustStatementUseCaseError, .cannotParseTrustRegistryDomain)
    }
  }

  func testExecute_fetchTrustStatementsThrows_throwsError() async throws {
    openIDRepositorySpy.fetchTrustStatementsFromIssuerDidThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(issuer: issuerMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_noTrustStatements_returnsNil() async throws {
    openIDRepositorySpy.fetchTrustStatementsFromIssuerDidReturnValue = []

    let trustStatement = try await useCase.execute(issuer: issuerMock)

    XCTAssertNil(trustStatement)
  }

  func testExecute_unsupportedTrustStatementVct_returnsNil() async throws {
    openIDRepositorySpy.fetchTrustStatementsFromIssuerDidReturnValue = [unsupportedTrustStatement]

    let trustStatement = try await useCase.execute(issuer: issuerMock)

    XCTAssertNil(trustStatement)
  }

  func testExecute_invalidTrustStatement_returnsNil() async throws {
    validateTrustStatementUseCaseSpy.executeReturnValue = false

    let trustStatement = try await useCase.execute(issuer: issuerMock)

    XCTAssertNil(trustStatement)
  }

  // MARK: Private

  private static let registryDomain = "registry.ch"
  private static let issuerDomain = "issuer.ch"

  private var issuerMock = "did:tdw:\(issuerDomain)"
  private let trustStatementMock = TrustStatementPayload.Mock.validSample

  private var trustRegistryRepositorySpy = TrustRegistryRepositoryProtocolSpy()
  private var openIDRepositorySpy = OpenIDRepositoryProtocolSpy()
  private var validateTrustStatementUseCaseSpy = ValidateTrustStatementUseCaseProtocolSpy()

  private var useCase: FetchTrustStatementUseCase!

  private var unsupportedTrustStatement: TrustStatement {
    var payload = TrustStatementPayload.Mock.validSamplePayload
    payload.vct = "unsupported"
    return TrustStatementPayload.Mock.createSdJWSMock(from: payload)
  }

  private func success() {
    trustRegistryRepositorySpy.getTrustRegistryDomainForReturnValue = Self.registryDomain
    openIDRepositorySpy.fetchTrustStatementsFromIssuerDidReturnValue = [ trustStatementMock ]
    validateTrustStatementUseCaseSpy.executeReturnValue = true
  }

  // swiftlint:enable force_unwrapping implicitly_unwrapped_optional
}
