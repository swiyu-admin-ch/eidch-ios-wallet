import BITOpenID
import BITSwiyuSharedKMP
import Foundation

// MARK: - RequestObject + DCQL

extension RequestObject {
  var dcqlQuery: DcqlQuery? {
    get throws {
      guard let payload = rawDcqlQuery else {
        return nil
      }
      guard let json = String(data: payload, encoding: .utf8) else {
        throw DcqlDecodingError.invalidPayloadEncoding
      }
      return try DcqlSupport().decodeDcqlQuery(json: json)
    }
  }
}

// MARK: - DcqlDecodingError

private enum DcqlDecodingError: Error {
  case invalidPayloadEncoding
}
