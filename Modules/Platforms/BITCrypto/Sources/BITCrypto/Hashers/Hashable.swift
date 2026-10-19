import Foundation
import Spyable

// MARK: - Hashable

/// A protocol for general-purpose hashing functions, designed to generate secure, one-way hashes for data integrity, digital signatures, and other cryptographic needs.
@Spyable
public protocol Hashable: Sendable {

  /// Produce a hash of the data given in parameter
  ///
  /// - Parameter data: the input data to hash
  /// - Returns: A hashed output
  func hash(_ data: Data) -> Data

  /// Combine the salt and the data given in parameter and produce a hash the result
  /// - Parameters:
  ///   - data: the input data to hash
  ///   - salt: the salt to combine with the data
  /// - Returns: A salted hash of the input data
  func salt(_ data: Data, withSalt salt: Data) -> Data

}

extension Hashable {

  public func salt(_ data: Data, withSalt salt: Data) -> Data {
    let saltedData = Data.combine(data, with: salt)
    return hash(saltedData)
  }

}
