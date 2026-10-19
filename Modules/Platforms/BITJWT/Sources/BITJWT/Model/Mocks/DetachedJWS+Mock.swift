#if DEBUG
import BITCrypto
import CryptoKit
import Foundation

extension DetachedJWS {

  public enum Mock {

    // MARK: Public

    public static let keyIdentifier = "did:webvh:scid:identifier-reg.example.com:api:v1:did:versioning#version-assertion-1"
    public static let payload = Data(#"{"platform":"ios"}"#.utf8)

    public static func rawJWS(
      algorithm: String = "ES256",
      keyIdentifier: String = Mock.keyIdentifier,
      payload: Data = Data(),
      signature: Data = Data("signature".utf8)) throws
      -> String
    {
      let encodedHeader = try encodedHeader(algorithm: algorithm, keyIdentifier: keyIdentifier)
      return [encodedHeader, payload.base64URLEncodedString(), signature.base64URLEncodedString()].joined(separator: ".")
    }

    public static func signed(over payload: Data, by signingKey: P256.Signing.PrivateKey, algorithm: String = "ES256") throws -> DetachedJWS {
      let encodedHeader = try encodedHeader(algorithm: algorithm, keyIdentifier: keyIdentifier)
      let signature = try signingKey.signature(for: Data(encodedHeader.utf8) + Data(".".utf8) + payload).rawRepresentation
      return try DetachedJWS(rawJWS: "\(encodedHeader)..\(signature.base64URLEncodedString())")
    }

    // MARK: Private

    private static func encodedHeader(algorithm: String, keyIdentifier: String) throws -> String {
      let header: [String: Any] = [
        "alg": algorithm,
        "b64": false,
        "crit": ["b64"],
        "kid": keyIdentifier,
        "typ": "JOSE",
      ]
      return try JSONSerialization.data(withJSONObject: header, options: [.sortedKeys]).base64URLEncodedString()
    }
  }
}
#endif
