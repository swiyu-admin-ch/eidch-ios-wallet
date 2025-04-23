#if DEBUG
import Foundation
@testable import BITJWT
@testable import BITTestingCore

// swiftlint: disable force_try

extension TokenStatusList: Mockable {

  enum Mock {

    // MARK: Internal

    static let sample: JWS<TokenStatusList> = decodeRawText(fromFile: "token-status-list")
    static let sampleData: Data = getData(fromFile: "token-status-list", ofType: "txt", bundle: Bundle.module) ?? Data()

    static let expired: JWS<TokenStatusList> = decodeRawText(fromFile: "token-status-list-expired")

    // MARK: Private

    private static func decodeRawText(fromFile filename: String) -> JWS<TokenStatusList> {
      let data = getData(fromFile: filename, ofType: "txt", bundle: Bundle.module) ?? Data()
      let decoder = JWSDecoder(dateDecodingStrategy: .secondsSince1970)
      return try! decoder.decode(TokenStatusList.self, from: data)
    }
  }
}
// swiftlint: enable all
#endif
