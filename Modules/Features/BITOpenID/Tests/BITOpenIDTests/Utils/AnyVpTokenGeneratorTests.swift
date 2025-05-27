import Factory
import XCTest
@testable import BITCrypto
@testable import BITJWT
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITSdJWTMocks
@testable import BITTestingCore

final class AnyVpTokenGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    mockKeyPair = KeyPair(identifier: mockIdentifier, algorithm: mockAlgorithm, privateKey: mockPrivateKey)

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

  private let mockPrivateKey: SecKey = SecKeyTestsHelper.createPrivateKey()
  private let mockIdentifier = UUID()
  private let mockAlgorithm = "ES256"
  private let mockReason = "mockReason"

  private var jwsEncoderMock: JWSEncoderMock<KeyBindingPayload>!
  private var generator: AnyVpTokenGenerator!
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
    } else {
      XCTAssertEqual(1 + nbOfDisclosures, disclosures.count)
      XCTAssertFalse(sha256HasherSpy.hashCalled)
    }
  }

  // swiftlint:enable all

}
