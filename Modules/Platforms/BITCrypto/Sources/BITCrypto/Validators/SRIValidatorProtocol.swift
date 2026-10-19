import Foundation
import Spyable

/// Ensuring the integrity of resources following Subresource Integrity (SRI) specification
/// https://www.w3.org/TR/SRI
@Spyable
public protocol SRIValidatorProtocol: Sendable {

  /// Validates the provided data against the given integrity hash-expression (e.g. "sha256-abc123").
  ///
  /// - Parameters:
  ///   - data: The resource data to be validated.
  ///   - integrity: The hash-expession integrity value to be checked.
  ///
  /// - Throws:
  ///   - `SRIError.malformedIntegrity` if integrity parameter is malformed (e.g. "sha256+abc123" instead of "sha256-abc123").
  ///   - `SRIError.unsupportedAlgorithm` if the integrity hash algorithm is not supported.
  ///
  /// - Returns: `true` if the integrity parameter matches the computed hash of the provided data;
  ///            otherwise `false`.
  func validate(_ data: Data, with integrity: String) throws -> Bool

}
