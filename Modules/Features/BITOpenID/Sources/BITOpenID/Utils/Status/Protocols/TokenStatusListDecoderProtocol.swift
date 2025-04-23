import BITJWT
import Foundation
import Spyable

// MARK: - TokenStatusListDecoderProtocol

@Spyable
protocol TokenStatusListDecoderProtocol {
  func decode(_ jws: JWS<TokenStatusList>, index: Int) throws -> StatusCode
}
