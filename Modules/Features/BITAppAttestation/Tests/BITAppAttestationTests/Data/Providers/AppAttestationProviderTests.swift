// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITAppAttestation
@testable import BITCrypto
@testable import BITJsonCanonicalizer
@testable import BITTestingCore

final class AppAttestationProviderTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.reset()
    registerMocks()
    provider = AppAttestationProvider()
    createSuccessState()
  }

  // MARK: - attestedKey

  func testAttestedKey_parameters_success() async throws {
    let result = try await provider.generateAttestedKey(with: mockChallenge)

    XCTAssertEqual(result.identifier, mockKeyIdentifier)
    XCTAssertEqual(result.clientData, mockClientData)

    XCTAssertTrue(deviceCheckAppAttestService.generateKeyCalled)
    XCTAssertEqual(deviceCheckAppAttestService.attestKeyClientDataHashReceivedArguments?.keyId, mockKeyIdentifier)
    XCTAssertEqual(deviceCheckAppAttestService.attestKeyClientDataHashReceivedArguments?.clientDataHash, mockClientHash)
    XCTAssertEqual(sha256Hasher.hashReceivedData, mockChallenge.data(using: .utf8))
  }

  func testAttestedKey_count_success() async throws {
    _ = try await provider.generateAttestedKey(with: mockChallenge)

    XCTAssertEqual(deviceCheckAppAttestService.generateKeyCallsCount, 1)
    XCTAssertEqual(deviceCheckAppAttestService.attestKeyClientDataHashCallsCount, 1)
    XCTAssertEqual(sha256Hasher.hashCallsCount, 1)
  }

  func testAttestedKey_unsupportedDevice_throws() async throws {
    deviceCheckAppAttestService.isSupported = false

    do {
      _ = try await provider.generateAttestedKey(with: mockChallenge)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? AppAttestationProviderError, .unsupportedDevice)
    }
  }

  func testAttestedKey_generateKeyFails_throws() async throws {
    deviceCheckAppAttestService.generateKeyThrowableError = TestingError.error

    do {
      _ = try await provider.generateAttestedKey(with: mockChallenge)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testAttestedKey_attestKeyFails_throws() async throws {
    deviceCheckAppAttestService.attestKeyClientDataHashThrowableError = TestingError.error

    do {
      _ = try await provider.generateAttestedKey(with: mockChallenge)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: - appAssertion

  func testAppAssertion_parameters_success() async throws {
    let mockClientDataData = try JSONEncoder(outputFormatting: [.sortedKeys]).encode(mockClientDataObject)
    let result = try await provider.generateAppAssertion(for: mockKeyIdentifier, with: mockClientDataObject)

    XCTAssertEqual(result, mockAppAssertion)

    XCTAssertEqual(deviceCheckAppAttestService.generateAssertionClientDataHashReceivedArguments?.keyId, mockKeyIdentifier)
    XCTAssertEqual(deviceCheckAppAttestService.generateAssertionClientDataHashReceivedArguments?.clientDataHash, mockClientHash)
    XCTAssertEqual(jsonCanonicalizer.canonicalizeDataReceivedData, mockClientDataData)
    XCTAssertEqual(sha256Hasher.hashReceivedData, mockClientData)
  }

  func testAppAssertion_count_success() async throws {
    let result = try await provider.generateAppAssertion(for: mockKeyIdentifier, with: mockClientDataObject)

    XCTAssertEqual(result, mockAppAssertion)

    XCTAssertEqual(deviceCheckAppAttestService.generateAssertionClientDataHashCallsCount, 1)
    XCTAssertEqual(sha256Hasher.hashCallsCount, 1)
    XCTAssertEqual(jsonCanonicalizer.canonicalizeDataCallsCount, 1)
  }

  func testAppAssertion_unsupportedDevice_throws() async throws {
    deviceCheckAppAttestService.isSupported = false

    do {
      _ = try await provider.generateAppAssertion(for: mockKeyIdentifier, with: mockClientDataObject)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? AppAttestationProviderError, .unsupportedDevice)
    }
  }

  func testAppAssertion_generateAssertionFails_throws() async throws {
    deviceCheckAppAttestService.generateAssertionClientDataHashThrowableError = TestingError.error

    do {
      _ = try await provider.generateAppAssertion(for: mockKeyIdentifier, with: mockClientDataObject)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testAppAssertion_jsonCanonicalizationFails_throws() async throws {
    jsonCanonicalizer.canonicalizeDataThrowableError = TestingError.error

    do {
      _ = try await provider.generateAppAssertion(for: mockKeyIdentifier, with: mockClientDataObject)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let mockClientHash = "mock_client_hash".data(using: .utf8)!
  private let mockClientData = "mock_client_data".data(using: .utf8)!
  private let mockAppAssertion = "mock_app_assertion".data(using: .utf8)!
  private let mockChallenge = "mock_challenge"
  private let mockKeyIdentifier = "mock_key_identifier"
  private let mockClientDataObject = ClientDataObject.Mock.sample
  private var provider: AppAttestationProvider!
  private var sha256Hasher: HashableSpy!
  private var deviceCheckAppAttestService: DeviceCheckAppAttestServiceProtocolSpy!
  private var jsonCanonicalizer: JsonCanonicalizerProtocolSpy!

  private func createSuccessState() {
    sha256Hasher.hashReturnValue = mockClientHash
    deviceCheckAppAttestService.isSupported = true
    deviceCheckAppAttestService.generateKeyReturnValue = mockKeyIdentifier
    deviceCheckAppAttestService.attestKeyClientDataHashReturnValue = mockClientData
    deviceCheckAppAttestService.generateAssertionClientDataHashReturnValue = mockAppAssertion
    jsonCanonicalizer.canonicalizeDataReturnValue = mockClientData
  }

  private func registerMocks() {
    sha256Hasher = HashableSpy()
    jsonCanonicalizer = JsonCanonicalizerProtocolSpy()
    deviceCheckAppAttestService = DeviceCheckAppAttestServiceProtocolSpy()

    Container.shared.sha256Hasher.register { self.sha256Hasher }
    Container.shared.deviceCheckAppAttestService.register { self.deviceCheckAppAttestService }
    Container.shared.jsonCanonicalizer.register { self.jsonCanonicalizer }
  }

}

// swiftlint: enable implicitly_unwrapped_optional force_unwrapping
