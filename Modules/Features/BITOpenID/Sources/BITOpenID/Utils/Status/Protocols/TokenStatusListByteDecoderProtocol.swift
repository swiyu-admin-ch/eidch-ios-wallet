import Foundation
import Spyable

typealias StatusCode = Int

// MARK: - TokenStatusListByteDecoderProtocol

@Spyable
protocol TokenStatusListByteDecoderProtocol: Sendable {
  func decode(_ statusList: Data, bits: Int, index: Int) throws -> StatusCode
}
