#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT

// MARK: OpenIdConfigurationJWT.Mock

extension OpenIdConfigurationJWT: Mockable {
  struct Mock {
    static let sample: JWS<OpenIdConfigurationJWT> = createJWS(from: .Mock.sample)
    static let sampleData: Data = Mocker.getData(fromFile: "openid-configuration", bundle: Bundle.module) ?? Data()

    static func createJWS(from configuration: OpenIdConfiguration) -> JWS<OpenIdConfigurationJWT> {
      let jwt = OpenIdConfigurationJWT(subject: "subject", issuedAt: Date(), expiredAt: nil, openIdConfiguration: configuration)
      return JWS(payload: jwt, rawPayload: "rawPayload", rawJWS: "rawJWS", header: JWSHeader(algorithm: JWTAlgorithm.ES256))
    }
  }
}
#endif
