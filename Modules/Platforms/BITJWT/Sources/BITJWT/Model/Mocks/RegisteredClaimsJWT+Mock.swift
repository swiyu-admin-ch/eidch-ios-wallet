#if DEBUG
import Foundation
@testable import BITCore
@testable import BITCrypto

// swiftlint:disable force_try

extension RegisteredClaimsJWT: Mockable {

  struct Mock {

    // MARK: Internal

    static let sample: JWS<RegisteredClaimsJWT> = createJws(from: sampleData)
    static let sampleData: Data = getData(fromFile: "jws-sample", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let sampleIsoDate: Data = getData(fromFile: "jws-iso-date", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let sampleEncodingData: String = getString(fromFile: "jws-sample-encoding", ofType: "txt", bundle: Bundle.module)

    static let noneAlgorithmData: Data = getData(fromFile: "jws-none-algorithm", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let invalidAlgorithmData: Data = getData(fromFile: "jws-invalid-algorithm", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let invalidTypeData: Data = getData(fromFile: "jws-invalid-type", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let noTypeData: Data = getData(fromFile: "jws-no-type", ofType: "txt", bundle: Bundle.module) ?? Data()

    static let registeredClaims = RegisteredClaimsJWT(
      issuer: "issuer",
      subject: "subject",
      audience: "audience",
      expiredAt: Date(timeIntervalSince1970: 1767168000),
      activatedAt: Date(timeIntervalSince1970: 1722499200),
      issuedAt: Date(timeIntervalSince1970: 1729168416))
    static let jwk = JWK(
      kty: "EC",
      kid: nil,
      crv: "P-521",
      x: "AAykRwVT5I7iJAI4ecePTQOmppfAK74l-RrOCw3BuyoRA0shf9IuShpJPt_FrJofH3ZJwwIZpPLRpJyUooeE4-CH",
      y: "AaiJnQbVybaNn6UYaa-uRCdCfFfywITZcUq_ux5uQN8J4ryU5Ce8eZNmF-VsYTLlQkrUAevfjbfqo6wzhu3cplas")

    // MARK: Private

    private static func createJws(from data: Data) -> JWS<RegisteredClaimsJWT> {
      let decoder = JWSDecoder(dateDecodingStrategy: .secondsSince1970)
      return try! decoder.decode(RegisteredClaimsJWT.self, from: data)
    }

  }
}
// swiftlint:enable all
#endif
