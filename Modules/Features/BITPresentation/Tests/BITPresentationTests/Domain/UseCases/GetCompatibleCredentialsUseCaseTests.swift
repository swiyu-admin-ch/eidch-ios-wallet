import Factory
import FactoryTesting
import Testing
@testable import BITAnyCredentialFormat
@testable import BITClaimsPathPointer
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITOpenID
@testable import BITPresentation
@testable import BITTestingCore

@Suite(.container)
struct GetCompatibleCredentialsUseCaseTests {

  // MARK: Lifecycle

  init() {
    mockMatchingPaths = [firstNamePath, lastNamePath]

    let credentialRepository = CredentialRepositoryProtocolSpy()
    let dcqlCredentialMatcherSpy = DcqlCredentialMatcherProtocolSpy()
    let selectCredentialBundleItemUseCaseSpy = SelectCredentialBundleItemUseCaseProtocolSpy()
    selectCredentialBundleItemUseCaseSpy.callAsFunctionClosure = {
      // swiftlint:disable force_unwrapping
      $0.bundleItems.first!
      // swiftlint:enable force_unwrapping
    }

    self.credentialRepository = credentialRepository
    self.dcqlCredentialMatcherSpy = dcqlCredentialMatcherSpy
    self.selectCredentialBundleItemUseCaseSpy = selectCredentialBundleItemUseCaseSpy

    Container.shared.credentialRepository.register { credentialRepository }
    Container.shared.dcqlCredentialMatcher.register { dcqlCredentialMatcherSpy }
    Container.shared.selectCredentialBundleItemUseCase.register { selectCredentialBundleItemUseCaseSpy }

    useCase = GetCompatibleCredentialsUseCase()

    credentialRepository.getAllAcceptedVerifiableCredentialsReturnValue = mockCredentials
    dcqlCredentialMatcherSpy.matchCredentialsWithReturnValue = mockCredentials.map {
      CompatibleCredential(credential: $0, presentingPaths: mockMatchingPaths, dcqlQueryId: "vct")
    }
  }

  // MARK: Internal

  @Test
  func callAsFunction_matchingCredentials_returnsCompatibleCredentials() async throws {
    let requestObject = RequestObjectJWS.Mock.sample.payload
    let expectedCredentials = [
      CompatibleCredential(credential: mockCredentials[0], presentingPaths: mockMatchingPaths, dcqlQueryId: "pid"),
    ]
    dcqlCredentialMatcherSpy.matchCredentialsWithReturnValue = expectedCredentials

    let credentials = try await useCase(using: requestObject)

    #expect(credentials == expectedCredentials)
    #expect(credentialRepository.getAllAcceptedVerifiableCredentialsCalled)
    #expect(dcqlCredentialMatcherSpy.matchCredentialsWithCalled)
    #expect(dcqlCredentialMatcherSpy.matchCredentialsWithReceivedArguments?.credentials == mockCredentials)
  }

  @Test
  func callAsFunction_noMatchingCredentials_returnsEmpty() async throws {
    dcqlCredentialMatcherSpy.matchCredentialsWithReturnValue = []

    let credentials = try await useCase(using: RequestObjectJWS.Mock.sample.payload)

    #expect(credentials.isEmpty)
    #expect(credentialRepository.getAllAcceptedVerifiableCredentialsCalled)
    #expect(dcqlCredentialMatcherSpy.matchCredentialsWithCalled)
  }

  @Test
  func callAsFunction_emptyWallet() async throws {
    credentialRepository.getAllAcceptedVerifiableCredentialsReturnValue = []

    let credentials = try await useCase(using: RequestObjectJWS.Mock.sample.payload)

    #expect(credentials.isEmpty)
    #expect(credentialRepository.getAllAcceptedVerifiableCredentialsCalled)
    #expect(!dcqlCredentialMatcherSpy.matchCredentialsWithCalled)
  }

  @Test
  func callAsFunction_matcherThrows_throws() async {
    dcqlCredentialMatcherSpy.matchCredentialsWithThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await useCase(using: RequestObjectJWS.Mock.sample.payload)
    }
  }

  @Test
  func callAsFunction_compatibleStatus_returnsCompatibleCredentials() async throws {
    let statuses: [CredentialStatus] = [.suspended, .unsupported, .valid, .unknown, .businessExpired]
    let credentials = statuses.map { makeCredential(status: $0) }
    credentialRepository.getAllAcceptedVerifiableCredentialsReturnValue = credentials
    dcqlCredentialMatcherSpy.matchCredentialsWithReturnValue = credentials.map {
      CompatibleCredential(credential: $0, presentingPaths: mockMatchingPaths, dcqlQueryId: "vct")
    }

    let matchedCredentials = try await useCase(using: RequestObjectJWS.Mock.sample.payload)
    let returnedStatuses = try matchedCredentials.map { try selectCredentialBundleItemUseCaseSpy($0.credential).status }

    #expect(returnedStatuses == statuses)
  }

  @Test
  func callAsFunction_incompatibleStatuses_returnsEmpty() async throws {
    let statuses: [CredentialStatus] = [.revoked, .expired, .notYetValid]
    credentialRepository.getAllAcceptedVerifiableCredentialsReturnValue = statuses.map { makeCredential(status: $0) }

    let credentials = try await useCase(using: RequestObjectJWS.Mock.sample.payload)

    #expect(credentials.isEmpty)
  }

  // MARK: Private

  private let mockCredentials: [VerifiableCredential] = [.Mock.sample, .Mock.diploma, .Mock.sample]
  private let firstNamePath: ClaimsPathPointer = [.string("firstName")]
  private let lastNamePath: ClaimsPathPointer = [.string("lastName")]
  private let mockMatchingPaths: [ClaimsPathPointer]

  private let credentialRepository: CredentialRepositoryProtocolSpy
  private let dcqlCredentialMatcherSpy: DcqlCredentialMatcherProtocolSpy
  private let selectCredentialBundleItemUseCaseSpy: SelectCredentialBundleItemUseCaseProtocolSpy

  private let useCase: GetCompatibleCredentialsUseCase

  private func makeCredential(status: CredentialStatus = .valid) -> VerifiableCredential {
    var credential = VerifiableCredential.Mock.sample
    if let bundleItemIndex = credential.bundleItems.firstIndex(where: { $0.id == credential.nextPresentableBundleItemId }) {
      credential.bundleItems[bundleItemIndex].status = status
    }
    return credential
  }
}
