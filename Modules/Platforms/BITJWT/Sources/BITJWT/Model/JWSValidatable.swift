import BITCrypto
import Foundation

// MARK: - JWSValidatable

public protocol JWSValidatable {

  var header: JWSHeader { get }
  var rawJWS: String { get }

}
