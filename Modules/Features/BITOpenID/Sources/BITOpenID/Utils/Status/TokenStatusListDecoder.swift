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

    let nsData = listData.dropFirst(2) as NSData // first two header bytes are not used

    let decompressedData = try nsData.decompressed(using: .zlib) as Data
    return try tokenStatusListByteDecoder.decode(decompressedData, bits: statusList.bits, index: index)
  }

  // MARK: Private

  @Injected(\.tokenStatusListByteDecoder) private var tokenStatusListByteDecoder: TokenStatusListByteDecoderProtocol

}
