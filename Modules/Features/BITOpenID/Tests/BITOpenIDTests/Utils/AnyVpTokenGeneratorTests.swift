import Factory
import XCTest
@testable import BITClaimsPathPointer
@testable import BITCrypto
@testable import BITJWT
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITTestingCore
@testable import BITVault

final class AnyVpTokenGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    sha256HasherSpy = HashableSpy()
    jwsEncoderMock = JWSEncoderMock()

    Container.shared.sha256Hasher.register { self.sha256HasherSpy }
    Container.shared.jwsEncoder.register { self.jwsEncoderMock }

    jwsEncoderMock.encodeUsingReturnValue = Self.mockJwtData
    jwsEncoderMock.receivedKeyPair = mockKeyPair
    sha256HasherSpy.hashReturnValue = Data()

    generator = AnyVpTokenGenerator()
  }

  func testVpTokenGeneration() throws {
    let requestedClaims: [ClaimsPathPointer] = [[.string("test_key_1")]]

    let vpToken = try generator.generate(requestObject: RequestObjectJWS.Mock.sample.payload, credential: mockCredential, keyPair: mockKeyPair, paths: requestedClaims, withOrigin: nil)

    asserts(vpToken, disclosureCount: 1, hasKeyBinding: true)
  }

  // MARK: Private

  // swiftlint:disable all

  private static let mockJwtString = "jwtString"
  private static let mockJwtData = mockJwtString.data(using: .utf8)!

  private var jwsEncoderMock: JWSEncoderMock<KeyBindingJWT>!
  private var generator: AnyVpTokenGenerator!
  private var sha256HasherSpy = HashableSpy()
  private var mockCredential = VcSdJWS.Mock.sample
  private let mockKeyPair = VaultKeyPair.Mock.ES256

  private func asserts(_ vpToken: VpToken, disclosureCount: Int, hasKeyBinding: Bool) {
    XCTAssertFalse(vpToken.isEmpty)
    let jwsParts = vpToken.split(separator: "~")
    if hasKeyBinding {
      XCTAssertEqual(2 + disclosureCount, jwsParts.count)
      XCTAssertTrue(sha256HasherSpy.hashCalled)
      XCTAssertEqual(String(jwsParts.last ?? ""), Self.mockJwtString)
    } else {
      XCTAssertEqual(1 + disclosureCount, jwsParts.count)
      XCTAssertFalse(sha256HasherSpy.hashCalled)
    }
  }

  // swiftlint:enable all

}
