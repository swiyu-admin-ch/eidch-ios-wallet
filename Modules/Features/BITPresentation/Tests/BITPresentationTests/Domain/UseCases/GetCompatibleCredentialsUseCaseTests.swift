// swiftlint:disable force_unwrapping
import Factory
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITAnyCredentialFormatMocks
@testable import BITClaimsPathPointer
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITOpenID
@testable import BITPresentation
@testable import BITTestingCore

// MARK: - GetCompatibleCredentialsUseCaseTests

final class GetCompatibleCredentialsUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    setUpMocks()

    useCase = GetCompatibleCredentialsUseCase()

    success()
  }

  func testExecute_matchingCredentials_returnsCompatibleCredentials() async throws {
    let requestObject = RequestObjectJWS.Mock.sample.payload
    let expectedCredentials = [
      CompatibleCredential(credential: mockCredentials[0], presentingPaths: mockMatchingPaths, dcqlQueryId: "pid"),
    ]
    dcqlCredentialMatcherSpy.matchCredentialsWithReturnValue = expectedCredentials

    let credentials = try await useCase.execute(using: requestObject)

    XCTAssertEqual(credentials, expectedCredentials)
    XCTAssertTrue(credentialRepository.getAllAcceptedVerifiableCredentialsCalled)
    XCTAssertTrue(dcqlCredentialMatcherSpy.matchCredentialsWithCalled)
    XCTAssertEqual(dcqlCredentialMatcherSpy.matchCredentialsWithReceivedArguments?.credentials, mockCredentials)
  }

  func testExecute_noMatchingCredentials_returnsEmpty() async throws {
    dcqlCredentialMatcherSpy.matchCredentialsWithReturnValue = []

    let credentials = try await useCase.execute(using: RequestObjectJWS.Mock.sample.payload)

    XCTAssertTrue(credentials.isEmpty)
    XCTAssertTrue(credentialRepository.getAllAcceptedVerifiableCredentialsCalled)
    XCTAssertTrue(dcqlCredentialMatcherSpy.matchCredentialsWithCalled)
  }

  func testExecute_emptyWallet() async throws {
    credentialRepository.getAllAcceptedVerifiableCredentialsReturnValue = []

    let credentials = try await useCase.execute(using: RequestObjectJWS.Mock.sample.payload)

    XCTAssertTrue(credentials.isEmpty)
    XCTAssertTrue(credentialRepository.getAllAcceptedVerifiableCredentialsCalled)
    XCTAssertFalse(dcqlCredentialMatcherSpy.matchCredentialsWithCalled)
  }

  func testExecute_matcherThrows_throws() async throws {
    dcqlCredentialMatcherSpy.matchCredentialsWithThrowableError = TestingError.error

    await XCTAssertThrowsErrorAsync(try await useCase.execute(using: RequestObjectJWS.Mock.sample.payload)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_missingQuery_throwsMissingQuery() async throws {
    await XCTAssertThrowsErrorAsync(try await useCase.execute(using: RequestObjectJWS.Mock.missingDcqlQuery.payload)) { error in
      XCTAssertEqual(error as? RequestObjectError, .missingQuery)
      XCTAssertFalse(credentialRepository.getAllAcceptedVerifiableCredentialsCalled)
      XCTAssertFalse(dcqlCredentialMatcherSpy.matchCredentialsWithCalled)
    }
  }

  func testExecute_compatibleStatus_returnsCompatibleCredentials() async throws {
    let statuses: [CredentialStatus] = [.valid, .suspended, .unsupported, .unknown, .businessExpired]
    let credentials = statuses.map { makeCredential(status: $0) }
    credentialRepository.getAllAcceptedVerifiableCredentialsReturnValue = credentials
    dcqlCredentialMatcherSpy.matchCredentialsWithReturnValue = credentials.map {
      CompatibleCredential(credential: $0, presentingPaths: mockMatchingPaths, dcqlQueryId: "vct")
    }

    useCase = GetCompatibleCredentialsUseCase()

    let matchedCredentials = try await useCase.execute(using: RequestObjectJWS.Mock.sample.payload)
    let returnedStatuses = try matchedCredentials.map { try selectCredentialBundleItemUseCaseSpy($0.credential).status }

    XCTAssertEqual(returnedStatuses, statuses)
  }

  func testExecute_incompatibleStatuses_returnsEmpty() async throws {
    let statuses: [CredentialStatus] = [.revoked, .expired, .notYetValid]
    credentialRepository.getAllAcceptedVerifiableCredentialsReturnValue = statuses.map { makeCredential(status: $0) }

    let credentials = try await useCase.execute(using: RequestObjectJWS.Mock.sample.payload)

    XCTAssertTrue(credentials.isEmpty)
  }

  // MARK: Private

  private let mockCredentials: [VerifiableCredential] = [.Mock.sample, .Mock.diploma, .Mock.sample]
  private let mockAnyCredential = MockAnyCredential()
  private let firstNamePath: ClaimsPathPointer = [.string("firstName")]
  private let lastNamePath: ClaimsPathPointer = [.string("lastName")]
  private var mockMatchingPaths = [ClaimsPathPointer]()

  private var credentialRepository = CredentialRepositoryProcotolSpy()
  private var dcqlCredentialMatcherSpy = DcqlCredentialMatcherProtocolSpy()
  private var selectCredentialBundleItemUseCaseSpy = SelectCredentialBundleItemUseCaseProtocolSpy()

  private var useCase = GetCompatibleCredentialsUseCase()

  private func setUpMocks() {
    mockMatchingPaths = [firstNamePath, lastNamePath]

    credentialRepository = CredentialRepositoryProcotolSpy()
    dcqlCredentialMatcherSpy = DcqlCredentialMatcherProtocolSpy()
    selectCredentialBundleItemUseCaseSpy = SelectCredentialBundleItemUseCaseProtocolSpy()
    selectCredentialBundleItemUseCaseSpy.callAsFunctionClosure = {
      $0.bundleItems.first!
    }

    Container.shared.credentialRepository.register { self.credentialRepository }
    Container.shared.dcqlCredentialMatcher.register { self.dcqlCredentialMatcherSpy }
    Container.shared.selectCredentialBundleItemUseCase.register { self.selectCredentialBundleItemUseCaseSpy }
  }

  private func success() {
    credentialRepository.getAllAcceptedVerifiableCredentialsReturnValue = mockCredentials
    dcqlCredentialMatcherSpy.matchCredentialsWithReturnValue = mockCredentials.map {
      CompatibleCredential(credential: $0, presentingPaths: mockMatchingPaths, dcqlQueryId: "vct")
    }
  }

  private func makeCredential(status: CredentialStatus = .valid) -> VerifiableCredential {
    var credential = VerifiableCredential.Mock.sample
    if let bundleItemIndex = credential.bundleItems.firstIndex(where: { $0.id == credential.nextPresentableBundleItemId }) {
      credential.bundleItems[bundleItemIndex].status = status
    }
    return credential
  }

}
