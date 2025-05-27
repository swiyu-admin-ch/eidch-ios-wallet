import Factory
import XCTest
@testable import BITCrypto
@testable import BITJWT
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITSdJWTMocks
@testable import BITTestingCore

// swiftlint: disable force_unwrapping implicitly_unwrapped_optional

final class VcSdJwtVpTokenGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    mockKeyPair = KeyPair(identifier: mockIdentifier, algorithm: mockAlgorithm, privateKey: mockPrivateKey)

    sha256HasherSpy = HashableSpy()
    jwsEncoderMock = JWSEncoderMock()

    Container.shared.sha256Hasher.register { self.sha256HasherSpy }
    Container.shared.jwsEncoder.register { self.jwsEncoderMock }

    jwsEncoderMock.encodeUsingReturnValue = Self.mockJwtData
    sha256HasherSpy.hashReturnValue = Data()

    generator = VcSdJwtVpTokenGenerator()
  }

  func testGenerate_oneClaimRequested() throws {
    let requestedClaims = [ "firstName" ]

    let vpToken = try generator.generate(requestObject: .Mock.VcSdJwt.sample, credential: mockCredential, keyPair: mockKeyPair, fields: requestedClaims)

    asserts(vpToken, nbOfDisclosures: 1, hasKeyBinding: true)
  }

  func testGenerate_severalClaimsRequested() throws {
    let requestedClaims: [String] = ["firstName", "lastName"]

    let vpToken = try generator.generate(requestObject: .Mock.VcSdJwt.sample, credential: mockCredential, keyPair: mockKeyPair, fields: requestedClaims)

    asserts(vpToken, nbOfDisclosures: 2, hasKeyBinding: true)
  }

  func testGenerate_noClaimsRequested() throws {
    let requestedClaims: [String] = []

    let vpToken = try generator.generate(requestObject: .Mock.VcSdJwt.sample, credential: mockCredential, keyPair: mockKeyPair, fields: requestedClaims)

    asserts(vpToken, nbOfDisclosures: 0, hasKeyBinding: true)
  }

  func testGenerate_noKeyBinding() throws {
    let mockCredentialNoKeyBinding = VcSdJwtPayload.Mock.noKeyBinding
    let requestedClaims = [ "firstName" ]

    let vpToken = try generator.generate(requestObject: .Mock.VcSdJwt.sample, credential: mockCredentialNoKeyBinding, keyPair: nil, fields: requestedClaims)

    asserts(vpToken, nbOfDisclosures: 1, hasKeyBinding: false)
  }

  func testGenerate_missingClaim() throws {
    let requestedClaims: [String] = [
      "firstName",
      "special-claim",
    ]

    do {
      _ = try generator.generate(requestObject: .Mock.VcSdJwt.sample, credential: mockCredential, keyPair: mockKeyPair, fields: requestedClaims)
    } catch {
      XCTAssertFalse(sha256HasherSpy.hashCalled)
    }
  }

  // MARK: Private

  private static let mockJwtString = "jwtString"
  private static let mockJwtData = mockJwtString.data(using: .utf8)!

  private let mockPrivateKey: SecKey = SecKeyTestsHelper.createPrivateKey()
  private let mockIdentifier = UUID()
  private let mockAlgorithm = "ES256"
  private let mockReason = "mockReason"

  private var jwsEncoderMock: JWSEncoderMock<KeyBindingPayload>!
  private var generator: VcSdJwtVpTokenGenerator!
  private var sha256HasherSpy = HashableSpy()
  private var mockCredential = VcSdJwtPayload.Mock.sample
  private var mockKeyPair: KeyPair!

  private func asserts(_ vpToken: VpToken, nbOfDisclosures: Int, hasKeyBinding: Bool) {
    XCTAssertFalse(vpToken.isEmpty)
    let disclosures = vpToken.split(separator: "~")
    if hasKeyBinding {
      XCTAssertEqual(2 + nbOfDisclosures, disclosures.count)
      XCTAssertTrue(sha256HasherSpy.hashCalled)
      XCTAssertEqual(String(disclosures.last ?? ""), Self.mockJwtString)
      XCTAssertEqual(jwsEncoderMock.receivedKeyPair, mockKeyPair)
    } else {
      XCTAssertEqual(1 + nbOfDisclosures, disclosures.count)
      XCTAssertFalse(sha256HasherSpy.hashCalled)
    }
  }

}

// swiftlint: enable all
