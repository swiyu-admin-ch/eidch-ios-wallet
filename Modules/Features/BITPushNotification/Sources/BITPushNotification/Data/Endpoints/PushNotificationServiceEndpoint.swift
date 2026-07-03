import BITNetworking
import Factory
import Foundation
import Moya

// MARK: - PushNotificationServiceChallengeEndpoint

enum PushNotificationServiceChallengeEndpoint {
  static var url: URL {
    URL(target: PushNotificationServiceEndpoint.challenge)
  }
}

// MARK: - PushNotificationServiceEndpoint

enum PushNotificationServiceEndpoint: TargetType {
  case challenge
  case delete(pushId: String)
  case register(PushRegistrationBody)
  case update(PushUpdateBody)

  // MARK: Internal

  var baseURL: URL {
    Container.shared.pushNotificationUrl()
  }

  var path: String {
    switch self {
    case .register:
      "targets"
    case .delete(let pushId):
      "targets/\(pushId)"
    case .update:
      "targets"
    case .challenge:
      "targets/challenge"
    }
  }

  var method: Moya.Method {
    switch self {
    case .delete:
      .delete
    case .update:
      .patch
    case .register:
      .post
    case .challenge:
      .get
    }
  }

  var task: Moya.Task {
    switch self {
    case .register(let body as Encodable),
         .update(let body as Encodable):
      .requestJSONEncodable(body)
    case .challenge,
         .delete:
      .requestPlain
    }
  }

  var headers: [String: String]? {
    switch self {
    case .challenge:
      NetworkHeader.standard.raw
    case .delete,
         .register,
         .update:
      nil // Handle by ClientAttestationPlugin
    }
  }
}
