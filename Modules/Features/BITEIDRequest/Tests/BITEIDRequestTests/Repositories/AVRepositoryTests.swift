import Factory
import Foundation
import Moya
import Testing
@testable import BITAppAttestation
@testable import BITCrypto
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITNetworking
@testable import BITOpenID
@testable import BITTestingCore
@testable import BITVault

struct AVRepositoryTests {

  // MARK: Lifecycle

  init() {
    guard let url = URL(string: "some://av-url") else {
      fatalError("Could not create initial URL")
    }

    Container.shared.avBaseUrl.register { url }
    NetworkContainer.shared.stubClosure.register {
      { _ in .immediate }
    }

    let dpopGenerator = DPoPGeneratorProtocolSpy()
    dpopGenerator.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReturnValue = DPoPJWT.Mock.sample
    self.dpopGenerator = dpopGenerator

    let sha256Hasher = HashableSpy()
    sha256Hasher.hashReturnValue = mockHash
    self.sha256Hasher = sha256Hasher

    let appAttestationKeyRepository = AppAttestationKeyRepositoryProtocolSpy()
    appAttestationKeyRepository.getForReturnValue = mockKeyPair
    self.appAttestationKeyRepository = appAttestationKeyRepository

    Container.shared.dpopGenerator.register { dpopGenerator }
    Container.shared.appAttestationKeyRepository.register { appAttestationKeyRepository }
    Container.shared.sha256Hasher.register { sha256Hasher }

    repository = AVRepository()
  }

  // MARK: Internal

  // MARK: - submitRequest()

  @Test
  func submitRequest_success() async throws {
    let requestBody = try JSONEncoder().encode(mockSubmitFileBody)
    mockResponse(code: 200, data: requestBody)

    let endpoint = AVRepositoryEndpoint.submit(caseId: mockCaseId, body: requestBody)

    try await repository.submitRequest(caseId: mockCaseId, authJwt: mockAuthJwt, files: mockFiles)

    #expect(appAttestationKeyRepository.getForCallsCount == 1)
    #expect(appAttestationKeyRepository.getForReceivedType == .client)

    #expect(sha256Hasher.hashCallsCount == mockFiles.count)

    #expect(dpopGenerator.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersCallsCount == 1)
    #expect(dpopGenerator.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.method == "POST")
    #expect(dpopGenerator.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.url == URL(target: endpoint))
    #expect(dpopGenerator.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.keyPair == mockKeyPair)
    #expect(dpopGenerator.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.accessToken == mockAuthJwt)
  }

  @Test
  func submitRequest_dPopGenerationFails_throwsError() async throws {
    dpopGenerator.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersThrowableError = TestingError.error

    mockResponse(code: 200)

    await #expect(throws: TestingError.error) {
      try await repository.submitRequest(caseId: mockCaseId, authJwt: mockAuthJwt, files: mockFiles)
    }
  }

  @Test
  func submitRequest_fetchAttestationKeyFails_throwsError() async throws {
    appAttestationKeyRepository.getForThrowableError = TestingError.error

    mockResponse(code: 200)

    await #expect(throws: TestingError.error) {
      try await repository.submitRequest(caseId: mockCaseId, authJwt: mockAuthJwt, files: mockFiles)
    }
  }

  @Test
  func submitRequest_networkError_throwsError() async throws {
    mockResponse(code: 404)

    await #expect(throws: NetworkError.self) {
      try await repository.submitRequest(caseId: mockCaseId, authJwt: mockAuthJwt, files: mockFiles)
    }
  }

  // MARK: - submitFile()

  @Test
  func submitFile_success() async throws {
    mockResponse(code: 200)

    let endpoint = AVRepositoryEndpoint.submitFile(caseId: mockCaseId, file: mockFile)

    try await repository.submitFile(mockFile, caseId: mockCaseId, authJwt: mockAuthJwt, nil)

    #expect(appAttestationKeyRepository.getForCallsCount == 1)
    #expect(appAttestationKeyRepository.getForReceivedType == .client)

    #expect(dpopGenerator.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersCallsCount == 1)
    #expect(dpopGenerator.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.method == "POST")
    #expect(dpopGenerator.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.url == URL(target: endpoint))
    #expect(dpopGenerator.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.keyPair == mockKeyPair)
    #expect(dpopGenerator.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.accessToken == mockAuthJwt)
    #expect(dpopGenerator.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.requestBody == mockFile.data)
  }

  @Test
  func submitFile_dPopGenerationFails_throwsError() async throws {
    dpopGenerator.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersThrowableError = TestingError.error

    mockResponse(code: 200)

    await #expect(throws: TestingError.error) {
      try await repository.submitFile(mockFile, caseId: mockCaseId, authJwt: mockAuthJwt, nil)
    }
  }

  @Test
  func submitFile_fetchAttestationKeyFails_throwsError() async throws {
    appAttestationKeyRepository.getForThrowableError = TestingError.error

    mockResponse(code: 200)

    await #expect(throws: TestingError.error) {
      try await repository.submitFile(mockFile, caseId: mockCaseId, authJwt: mockAuthJwt, nil)
    }
  }

  @Test
  func submitFile_networkError_throwsError() async throws {
    mockResponse(code: 404)

    await #expect(throws: NetworkError.self) {
      try await repository.submitFile(mockFile, caseId: mockCaseId, authJwt: mockAuthJwt, nil)
    }
  }

  // MARK: Private

  private let mockCaseId = "caseId"
  private let mockAuthJwt = "authJwt"
  private let mockFile = EIDRequestCaseFile.Mock.sample
  private let mockFiles = EIDRequestCaseFile.Mock.sampleArray
  private let mockKeyPair = VaultKeyPair.Mock.ES256
  private let mockHash = Data([0xFB, 0xFF])
  private let mockSubmitFileBody = [EIDRequestSubmitFile(fileName: "fileName_1", hash: "hash_1"), EIDRequestSubmitFile(fileName: "fileName_2", hash: "hash_2")]

  private var repository: AVRepository

  private let sha256Hasher: HashableSpy
  private let dpopGenerator: DPoPGeneratorProtocolSpy
  private let appAttestationKeyRepository: AppAttestationKeyRepositoryProtocolSpy

  private func mockResponse(code: Int, data: Data = Data()) {
    NetworkContainer.shared.endpointClosure.register {
      .networkResponse(code, data)
    }
  }
}
