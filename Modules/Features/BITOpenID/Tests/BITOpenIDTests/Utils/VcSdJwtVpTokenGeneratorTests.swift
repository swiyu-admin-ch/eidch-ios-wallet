import Factory
import XCTest
@testable import BITClaimsPathPointer
@testable import BITCrypto
@testable import BITJWT
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITTestingCore
@testable import BITVault

// swiftlint: disable force_unwrapping implicitly_unwrapped_optional

final class VcSdJwtVpTokenGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    sha256HasherSpy = HashableSpy()
    jwsEncoderMock = JWSEncoderMock()

    Container.shared.sha256Hasher.register { self.sha256HasherSpy }
    Container.shared.jwsEncoder.register { self.jwsEncoderMock }

    jwsEncoderMock.encodeUsingReturnValue = Self.mockJwtData
    sha256HasherSpy.hashReturnValue = Data()

    generator = VcSdJwtVpTokenGenerator()
  }

  func testGenerate_oneClaimRequested() throws {
    let requestedClaims = [Self.mockPath1]

    let vpToken = try generator.generate(requestObject: RequestObjectJWS.Mock.sample.payload, credential: mockCredential, keyPair: mockKeyPair, paths: requestedClaims)

    asserts(vpToken, disclosureCount: 1, hasKeyBinding: true)
  }

  func testGenerate_severalClaimsRequested() throws {
    let requestedClaims = [Self.mockPath1, Self.mockPath2]

    let vpToken = try generator.generate(requestObject: RequestObjectJWS.Mock.sample.payload, credential: mockCredential, keyPair: mockKeyPair, paths: requestedClaims)

    asserts(vpToken, disclosureCount: 2, hasKeyBinding: true)
  }

  func testGenerate_noClaimsRequested() throws {
    let requestedClaims = [ClaimsPathPointer]()

    let vpToken = try generator.generate(requestObject: RequestObjectJWS.Mock.sample.payload, credential: mockCredential, keyPair: mockKeyPair, paths: requestedClaims)

    asserts(vpToken, disclosureCount: 0, hasKeyBinding: true)
  }

  func testGenerate_noKeyBinding() throws {
    let mockCredentialNoKeyBinding = VcSdJWS.Mock.noKeyBinding
    let requestedClaims = [Self.mockPath1]

    let vpToken = try generator.generate(requestObject: RequestObjectJWS.Mock.sample.payload, credential: mockCredentialNoKeyBinding, keyPair: nil, paths: requestedClaims)

    asserts(vpToken, disclosureCount: 1, hasKeyBinding: false)
  }

  func testGenerate_missingClaim() throws {
    let requestedClaims: [ClaimsPathPointer] = [
      Self.mockPath1,
      [.string("special-claim")],
    ]

    do {
      _ = try generator.generate(requestObject: RequestObjectJWS.Mock.sample.payload, credential: mockCredential, keyPair: mockKeyPair, paths: requestedClaims)
    } catch {
      XCTAssertFalse(sha256HasherSpy.hashCalled)
    }
  }

  // MARK: Private

  private static let mockJwtString = "jwtString"
  private static let mockPath1: ClaimsPathPointer = [.string("test_key_1")]
  private static let mockPath2: ClaimsPathPointer = [.string("test_key_2")]
  private static let mockJwtData = mockJwtString.data(using: .utf8)!

  private let mockKeyPair = VaultKeyPair.Mock.ES256

  private var jwsEncoderMock: JWSEncoderMock<KeyBindingJWT>!
  private var generator: VcSdJwtVpTokenGenerator!
  private var sha256HasherSpy = HashableSpy()
  private var mockCredential = VcSdJWS.Mock.sample

  private func asserts(_ vpToken: VpToken, disclosureCount: Int, hasKeyBinding: Bool) {
    XCTAssertFalse(vpToken.isEmpty)
    let jwsParts = vpToken.split(separator: "~")
    if hasKeyBinding {
      XCTAssertEqual(2 + disclosureCount, jwsParts.count)
      XCTAssertTrue(sha256HasherSpy.hashCalled)
      XCTAssertEqual(String(jwsParts.last ?? ""), Self.mockJwtString)
      XCTAssertEqual(jwsEncoderMock.receivedKeyPair, mockKeyPair)
    } else {
      XCTAssertEqual(1 + disclosureCount, jwsParts.count)
      XCTAssertFalse(sha256HasherSpy.hashCalled)
    }
  }

}

// swiftlint: enable all
