import Factory
import RealmSwift
import XCTest
@testable import BITAppAttestation
@testable import BITJWT
@testable import BITLocalAuthentication
@testable import BITTestingCore
@testable import BITVault

// swiftlint: disable implicitly_unwrapped_optional force_unwrapping

final class ClientAttestationRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.reset()
    Container.shared.realmDataStoreConfiguration.register { Realm.Configuration(inMemoryIdentifier: "inMemory") }
    registerMocks()
    repository = ClientAttestationRepository()
    createSuccessState()
  }

  func testGet_withoutCache_fetchesAndStores() async throws {
    let result = try await repository.get(using: context)

    XCTAssertEqual(result, mockClientAttestation)
    XCTAssertEqual(attestationServiceRepository.fetchChallengeCallsCount, 1)
    XCTAssertEqual(appAttestationProvider.generateAttestedKeyWithCallsCount, 1)
    XCTAssertEqual(appAttestationProvider.generateAppAssertionForWithCallsCount, 1)
    XCTAssertEqual(appAttestationKeyRepository.createForWithCallsCount, 1)
    XCTAssertEqual(clientAttestationValidator.callAsFunctionCallsCount, 1)
    let receivedContext = appAttestationKeyRepository.createForWithReceivedArguments?.context as? LAContextProtocolSpy
    XCTAssertTrue(receivedContext === context)
  }

  func testGet_withValidCached_returnsCached_withoutFetching() async throws {
    _ = try await repository.create(mockClientAttestation)

    let result = try await repository.get(using: context)

    XCTAssertEqual(result, mockClientAttestation)
    XCTAssertEqual(attestationServiceRepository.fetchChallengeCallsCount, 0)
    XCTAssertEqual(appAttestationProvider.generateAttestedKeyWithCallsCount, 0)
    XCTAssertEqual(appAttestationKeyRepository.createForWithCallsCount, 0)
  }

  func testGet_withExpiredCached_deletesAndRefetches() async throws {
    _ = try await repository.create(makePersistableExpiredClientAttestation())

    let result = try await repository.get(using: context)

    XCTAssertEqual(result, mockClientAttestation)
    XCTAssertEqual(attestationServiceRepository.fetchChallengeCallsCount, 1)
    XCTAssertEqual(appAttestationProvider.generateAttestedKeyWithCallsCount, 1)
    XCTAssertEqual(appAttestationKeyRepository.createForWithCallsCount, 1)
  }

  func testGet_withInvalidCached_deletesAndRefetches() async throws {
    clientAttestationValidator.callAsFunctionClosure = { [unowned clientAttestationValidator] _ in
      clientAttestationValidator.callAsFunctionCallsCount > 1
    }
    _ = try await repository.create(mockClientAttestation)

    let result = try await repository.get(using: context)

    XCTAssertEqual(result, mockClientAttestation)
    XCTAssertEqual(attestationServiceRepository.fetchChallengeCallsCount, 1)
    XCTAssertEqual(appAttestationProvider.generateAttestedKeyWithCallsCount, 1)
    XCTAssertEqual(appAttestationKeyRepository.createForWithCallsCount, 1)
  }

  func testGet_fetchFails_propagatesError() async throws {
    attestationServiceRepository.fetchChallengeThrowableError = TestingError.error

    do {
      _ = try await repository.get(using: context)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let mockClientAttestation = ClientAttestationJWT.Mock.sample
  private let mockExpiredClientAttestation = ClientAttestationJWT.Mock.sampleExpired
  private let mockAppAssertion = Data()
  private let mockAttestedKey = AppAttestedKey.Mock.sample
  private let mockChallengeResponse = AttestationChallenge.Response.Mock.sample
  private let mockKeyPair = VaultKeyPair.Mock.ES256

  private var repository: ClientAttestationRepositoryProtocol!
  private var context: LAContextProtocolSpy!
  private var appAttestationProvider: AppAttestationProviderProtocolSpy!
  private var attestationServiceRepository: AttestationServiceRepositoryProtocolSpy!
  private var appAttestationKeyRepository: AppAttestationKeyRepositoryProtocolSpy!
  private var clientAttestationValidator: ClientAttestationValidatorProtocolSpy!

  private func registerMocks() {
    context = LAContextProtocolSpy()
    appAttestationProvider = AppAttestationProviderProtocolSpy()
    attestationServiceRepository = AttestationServiceRepositoryProtocolSpy()
    appAttestationKeyRepository = AppAttestationKeyRepositoryProtocolSpy()
    clientAttestationValidator = ClientAttestationValidatorProtocolSpy()

    Container.shared.appAttestationProvider.register { self.appAttestationProvider }
    Container.shared.attestationServiceRepository.register { self.attestationServiceRepository }
    Container.shared.appAttestationKeyRepository.register { self.appAttestationKeyRepository }
    Container.shared.clientAttestationValidator.register { self.clientAttestationValidator }
  }

  private func createSuccessState() {
    attestationServiceRepository.fetchChallengeReturnValue = mockChallengeResponse.challenge
    attestationServiceRepository.fetchClientAttestationReturnValue = mockClientAttestation
    appAttestationProvider.generateAttestedKeyWithReturnValue = mockAttestedKey
    appAttestationProvider.generateAppAssertionForWithReturnValue = mockAppAssertion
    appAttestationKeyRepository.createForWithReturnValue = mockKeyPair
    clientAttestationValidator.callAsFunctionReturnValue = true
  }

  private func makePersistableExpiredClientAttestation() throws -> ClientAttestation {
    let headerData = try JSONSerialization.data(withJSONObject: ["alg": "ES256", "typ": "oauth-client-attestation+jwt", "kid": "did:tdw:example.com#key-1"], options: [])
    let payloadEncoder = JSONEncoder()
    payloadEncoder.dateEncodingStrategy = .secondsSince1970
    let payloadData = try payloadEncoder.encode(mockExpiredClientAttestation.payload)

    let compactJWS = [
      base64URLEncode(headerData),
      base64URLEncode(payloadData),
      base64URLEncode(Data("signature".utf8)),
    ].joined(separator: ".")

    return try JWSDecoder().decode(ClientAttestationJWT.self, from: Data(compactJWS.utf8))
  }

  private func base64URLEncode(_ data: Data) -> String {
    data.base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }
}
