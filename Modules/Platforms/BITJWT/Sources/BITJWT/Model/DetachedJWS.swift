import Foundation
import JWSETKit

/// A JWS whose payload is transported outside of the JWS itself, as specified by https://www.rfc-editor.org/rfc/rfc7797
public struct DetachedJWS: Equatable, Sendable {

  // MARK: Lifecycle

  public init(rawJWS: String) throws {
    let jws = try JSONWebSignaturePlain(from: rawJWS)

    header = try JWSHeader(from: jws)
    self.rawJWS = rawJWS
  }

  // MARK: Public

  /// The header of the detached JWS
  public let header: JWSHeader

  /// Raw detached JWS as it was received
  public let rawJWS: String

}
