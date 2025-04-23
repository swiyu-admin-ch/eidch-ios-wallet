import XCTest
@testable import BITAnyCredentialFormat
@testable import BITAnyCredentialFormatMocks
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITSdJWTMocks

// MARK: - VcSdJwtCredentialJsonGeneratorTests

final class VcSdJwtCredentialJsonGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    generator = VcSdJwtCredentialJsonGenerator()
  }

  func testGenerate_happyPath() throws {
    let mockCredential = VcSdJwtPayload.Mock.sample

    let json = try generator.generate(for: mockCredential)

    XCTAssertFalse(json.isEmpty)
  }

  func testGenerate_NotVcSdJwt_ThrowsError() throws {
    let mockAnyCredential: AnyCredential = MockAnyCredential()

    XCTAssertThrowsError(try generator.generate(for: mockAnyCredential)) { error in
      XCTAssertEqual(error as? CredentialFormatError, .formatNotSupported)
    }
  }

  // MARK: Private

  // swiftlint:disable all
  private var generator: VcSdJwtCredentialJsonGenerator!
  // swiftlint:enable all
}
