import BITCore
import BITJWT
import BITSdJWT
import Factory
import Foundation

// MARK: - TokenStatusListDecoder

struct TokenStatusListDecoder: TokenStatusListDecoderProtocol {

  // MARK: Internal

  enum DecoderError: Error {
    case invalidStatusJWT
  }

  func decode(_ jws: JWS<TokenStatusList>, index: Int) throws -> StatusCode {
    let statusList = jws.payload.statusList
    guard let listData = Data(base64URLEncoded: statusList.list) else {
      throw DecoderError.invalidStatusJWT
    }
    return try tokenStatusListByteDecoder.decode(listData.decompressed(), bits: statusList.bits, index: index)
  }

  // MARK: Private

  @Injected(\.tokenStatusListByteDecoder) private var tokenStatusListByteDecoder: TokenStatusListByteDecoderProtocol

}
