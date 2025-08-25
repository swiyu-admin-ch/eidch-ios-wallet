import BITJWT
import Factory
import Foundation

// MARK: - TokenStatusListByteDecoder

struct TokenStatusListByteDecoder: TokenStatusListByteDecoderProtocol {

  enum DecoderError: Error {
    case indexOutOfBounds
  }

  func decode(_ statusList: Data, bits: Int, index: Int) throws -> StatusCode {
    let entryIndex = index * bits / 8
    guard entryIndex < statusList.count else { throw DecoderError.indexOutOfBounds }
    let entryByte = statusList[entryIndex]
    // The starting position of the status in the Byte
    let bitIndex = (index * bits) % 8

    // Drop all bits larger than our status
    let mask = UInt8(((1 << bitIndex) << bits) - 1)
    let maskedByte = entryByte & mask

    // Shift the status to the start of the byte so 1 = revoked, 2 = suspended, etc, also removed all bits smaller than our status
    return StatusCode(maskedByte >> bitIndex)
  }
}
