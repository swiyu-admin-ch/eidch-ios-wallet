import Factory
import Foundation
import XCTest
@testable import BITJWT
@testable import BITOpenID
@testable import BITTestingCore

// MARK: - TokenStatusListDecoderTests

final class TokenStatusListDecoderTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    spyTokenStatusListByteDecoder = TokenStatusListByteDecoderProtocolSpy()

    Container.shared.tokenStatusListByteDecoder.register { self.spyTokenStatusListByteDecoder }

    decoder = TokenStatusListDecoder()
  }

  func testDecode_ValidJWT_ShouldReturnStatusCode() throws {
    let index = 1
    let statusCode = StatusCode(0)
    spyTokenStatusListByteDecoder.decodeBitsIndexReturnValue = statusCode

    let result = try decoder.decode(jwsMock, index: index)

    XCTAssertEqual(result, statusCode)
    XCTAssertEqual(2, spyTokenStatusListByteDecoder.decodeBitsIndexReceivedArguments?.bits)
    XCTAssertEqual(index, spyTokenStatusListByteDecoder.decodeBitsIndexReceivedArguments?.index)
    XCTAssertEqual(Data(fromArray: BYTES), spyTokenStatusListByteDecoder.decodeBitsIndexReceivedArguments?.statusList)
  }

  func testDecode_decoderThrows_throwsError() throws {
    spyTokenStatusListByteDecoder.decodeBitsIndexThrowableError = TestingError.error

    XCTAssertThrowsError(try decoder.decode(jwsMock, index: 0)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testDecode_notBase64EncodedList_throwsError() throws {
    let header = JWSHeader(algorithm: JWTAlgorithm.ES256)
    let payload = TokenStatusList(subject: "subject", issuedAt: Date(), statusList: TokenStatusList.StatusList(bits: 0, list: "%"))
    let jws: JWS<TokenStatusList> = JWS(payload: payload, rawPayload: "rawPayload", rawJWS: "rawJWS", header: header)

    XCTAssertThrowsError(try decoder.decode(jws, index: 0)) { error in
      XCTAssertEqual(error as? TokenStatusListDecoder.DecoderError, .invalidStatusJWT)
    }
  }

  // MARK: Private

  // swiftlint:disable all
  private var decoder: TokenStatusListDecoder!
  private var spyTokenStatusListByteDecoder: TokenStatusListByteDecoderProtocolSpy!
  private let jwsMock = TokenStatusList.Mock.sample
  // swiftlint:enable all
  private let BYTES = [0xC9, 0x44, 0xF9] as [UInt8] // "110010010100010011111001"
}

extension Data {
  fileprivate init(fromArray values: [some Any]) {
    self = values.withUnsafeBytes { Data($0) }
  }
}
