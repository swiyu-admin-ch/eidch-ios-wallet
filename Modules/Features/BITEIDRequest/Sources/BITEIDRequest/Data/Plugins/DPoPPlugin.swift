import BITOpenID
import Foundation
import Moya

struct DPoPPlugin: PluginType {

  init(dPop: DPoP, accessToken: String) {
    self.dPop = dPop
    self.accessToken = accessToken
  }

  func prepare(_ request: URLRequest, target: any TargetType) -> URLRequest {
    var request = request
    let authorizationValue = Self.dPopKey + " " + accessToken
    request.addValue(authorizationValue, forHTTPHeaderField: Self.authorizationKey)
    request.addValue(dPop.rawJWS, forHTTPHeaderField: Self.dPopKey)
    return request
  }

  private let dPop: DPoP
  private let accessToken: String

  private static let dPopKey = "DPoP"
  private static let authorizationKey = "Authorization"
}
