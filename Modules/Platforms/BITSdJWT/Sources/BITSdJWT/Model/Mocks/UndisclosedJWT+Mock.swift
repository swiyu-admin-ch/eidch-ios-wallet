#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT

struct UndisclosedJWT: JWT, Codable, Equatable {

  enum CodingKeys: String, CodingKey {
    case key = "test_key_1"
  }

  let type: String? = "undisclosed"

  let key: String?
}

extension UndisclosedJWT: Mockable {

  struct Mock {
    static let payload = UndisclosedJWT(key: "test_value_1")
    /**
      {
        "test_key_1": "test_value_1"
      }
     */
    private static let JWS = "eyJhbGciOiJFUzUxMiIsInR5cCI6InVuZGlzY2xvc2VkIn0.eyJ0ZXN0X2tleV8xIjoidGVzdF92YWx1ZV8xIn0.AFhn6lMNdVV7MXO-eqO3AUmlYQ-6DekiDahnIgEmRXhwqfay5HNXgricYvhOemz6dj_LESAiFyUlkCn2VAoSfLS0AWONepPQN26J-FHHepo6EA9MIVmTpeJGvK5etlvUfNjuln_3MWf6yG8SJqxroxtgfEw4LFtK5CEYREmqbJs_4sol~"
    static let data = Data(JWS.utf8)
  }
}

extension UndisclosedJWT {
  var issuer: String? {
    nil
  }

  var audience: String? {
    nil
  }

  var subject: String? {
    nil
  }

  var issuedAt: Date? {
    nil
  }

  var expiredAt: Date? {
    nil
  }

  var activatedAt: Date? {
    nil
  }
}
#endif
