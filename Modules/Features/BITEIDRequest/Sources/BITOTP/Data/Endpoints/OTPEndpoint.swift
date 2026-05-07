import BITCore
import BITEIDRequest
import BITNetworking
import Factory
import Foundation
import Moya

// MARK: - OTPEndpoint

enum OTPEndpoint {
  case request(OTPRequestBody)
  case verify(OTPVerifyBody)
}

// MARK: TargetType

extension OTPEndpoint: TargetType {

  // MARK: Internal

  var baseURL: URL {
    Container.shared.otpServiceBaseUrl()
  }

  var path: String {
    switch self {
    case .request:
      "otp/request"
    case .verify:
      "otp/verify"
    }
  }

  var method: Moya.Method {
    switch self {
    case .request,
         .verify:
      .post
    }
  }

  var task: Moya.Task {
    switch self {
    case .request(let body):
      .requestJSONEncodable(body)
    case .verify(let body):
      .requestJSONEncodable(body)
    }
  }

  var headers: [String: String]? {
    switch self {
    case .request,
         .verify:
      ["Accept-Language": acceptLanguage]
    }
  }

  var sampleData: Data {
    switch self {
    case .request,
         .verify:
      Data()
    }
  }

  // MARK: Private

  private var acceptLanguage: String {
    Container.shared.preferredUserLocales().first ?? UserLocale.defaultLocaleIdentifier
  }
}
