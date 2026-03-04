import Foundation
import JOSESwift

extension ECPublicKey {

  // MARK: Public

  public static func getSecKey(curve: String, x: String, y: String) throws -> SecKey? {
    guard let curve = ECCurveType(rawValue: curve) else { throw ECPublicKeyError.invalidInputData }

    let publicKey = ECPublicKey(crv: curve, x: x, y: y)

    return try publicKey.converted(to: SecKey.self)
  }

  // MARK: Internal

  func base64String() -> String? {
    jsonString()?.data(using: .utf8)?.base64EncodedString()
  }
}

// MARK: - ECPublicKeyError

enum ECPublicKeyError: Error {
  case invalidInputData
}
