import Foundation
import Moya

extension Response {

  public var isSuccessful: Bool {
    200..<300 ~= statusCode
  }

  public var error: Error {
    NetworkError(status: NetworkErrorStatus(httpStatusCode: statusCode), response: Moya.Response(statusCode: statusCode, data: data))
  }

}
