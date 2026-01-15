import Factory
import XCTest
@testable import BITCrypto
@testable import BITJWT
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITSdJWTMocks
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
    let requestedClaims = [ "firstName" ]

    let vpToken = try generator.generate(requestObject: .Mock.VcSdJwt.sample, credential: mockCredential, keyPair: mockKeyPair, fields: requestedClaims)

    asserts(vpToken, nbOfDisclosures: 1, hasKeyBinding: true)
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

  private func asserts(_ vpToken: VpToken, nbOfDisclosures: Int, hasKeyBinding: Bool) {
    XCTAssertFalse(vpToken.isEmpty)
    let disclosures = vpToken.split(separator: "~")
    if hasKeyBinding {
      XCTAssertEqual(2 + nbOfDisclosures, disclosures.count)
      XCTAssertTrue(sha256HasherSpy.hashCalled)
      XCTAssertEqual(String(disclosures.last ?? ""), Self.mockJwtString)
    } else {
      XCTAssertEqual(1 + nbOfDisclosures, disclosures.count)
      XCTAssertFalse(sha256HasherSpy.hashCalled)
    }
  }

  // swiftlint:enable all

}
