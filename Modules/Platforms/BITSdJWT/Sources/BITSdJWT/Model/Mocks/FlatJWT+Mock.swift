#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT

struct FlatJWT: JWT, Codable, Equatable {

  // MARK: Lifecycle

  init(testKey1: String? = nil, testKey2: String? = nil, testKey3: String? = nil) {
    self.testKey1 = testKey1
    self.testKey2 = testKey2
    self.testKey3 = testKey3
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case testKey1 = "test_key_1"
    case testKey2 = "test_key_2"
    case testKey3 = "test_key_3"
  }

  let type: String? = "flat"

  let testKey1: String?
  let testKey2: String?
  let testKey3: String?
}

extension FlatJWT: Mockable {

  struct Mock {

    // MARK: Internal

    static let payload = FlatJWT(testKey1: "test_value_1", testKey2: "test_value_2", testKey3: "test_value_3")
    /**
     {
       "_sd": [
         "YRLf606clwt4-hjyGze49ySFi6VCmwb9n5hwb4VUJSY",
         "QhuvIMQd5LyX8gOR3weVzSY0yGZGGHdVXY0E-NhhUfw",
         "ql6yBMb-5Ql1gG833J1o3poFIDLVt9Ck79astQeVYb0"
       ],
       "_sd_alg": "sha-256"
     }
     */
    static let JWS = "eyJhbGciOiJFUzUxMiIsInR5cCI6ImZsYXQifQ.eyJfc2QiOlsiWVJMZjYwNmNsd3Q0LWhqeUd6ZTQ5eVNGaTZWQ213YjluNWh3YjRWVUpTWSIsIlFodXZJTVFkNUx5WDhnT1Izd2VWelNZMHlHWkdHSGRWWFkwRS1OaGhVZnciLCJxbDZ5Qk1iLTVRbDFnRzgzM0oxbzNwb0ZJRExWdDlDazc5YXN0UWVWWWIwIl0sIl9zZF9hbGciOiJzaGEtMjU2In0.ANplFuJmpC3Ys7mlCxRpOtqZK45eK4Tp7UEL4o2Ng2otUcNhUi3816Jp85kAflt6y0hIw8QXTRElHxzQKDKPcAhcAYPmekYTtHJOPRJQYYW0O9YULbxHjqk4rhKBehwkmhMKnVEmOgPcu0wMjdTyzDyDrUMd5UYf-MnzVeS8yopmcn5w"
    static let data = JWS.sdJWSData(with: disclosures)
    static let dataWithDecoys = JWS.sdJWSData(with: [disclosure1])

    static let sha384Data = sha384JWS.sdJWSData(with: disclosures)
    static let sha512Data = sha512JWS.sdJWSData(with: disclosures)

    static let disclosures = [disclosure1, disclosure2, disclosure3]

    /// ["test_salt_1", "test_key_1", "test_value_1"]
    /// YRLf606clwt4-hjyGze49ySFi6VCmwb9n5hwb4VUJSY - SHA-256
    /// ouLWzsH--wYNXVB1qPDj3-MLkmI0JwbNvmuzz1RHMzcF4ut5P03wauYCqtEbynou - SHA-384
    /// h-hqZBKqJLOcSrDjjYz8vj34x9cLrEg3DDv7dkFs3CP0OgtmU-cpkInCOaa4TSAOozys4LUouw-jPmNK-3KzlQ - SHA-512
    static let disclosure1 = "WyJ0ZXN0X3NhbHRfMSIsICJ0ZXN0X2tleV8xIiwgInRlc3RfdmFsdWVfMSJd"

    /// ["test_salt_2", "test_key_2", "test_value_2"]
    /// QhuvIMQd5LyX8gOR3weVzSY0yGZGGHdVXY0E-NhhUfw - SHA-256
    /// C_whCEQGcf93_rVaXgR4RZuujCX0B9m9g0EA52SeJR6Am74pf3O_wzUzjSCI-0va - SHA-384
    /// gYZpXgFtOq1tFM5QjKBYocoXLt07rhGSDhYbVfC5RavuBziWgPdIbE0sZdrPm-p3rhA2id1QhuBgXQ87ZcWWLg - SHA-512
    static let disclosure2 = "WyJ0ZXN0X3NhbHRfMiIsICJ0ZXN0X2tleV8yIiwgInRlc3RfdmFsdWVfMiJd"

    /// ["test_salt_3", "test_key_3", "test_value_3"]
    /// ql6yBMb-5Ql1gG833J1o3poFIDLVt9Ck79astQeVYb0 - SHA-256
    /// v03e8GRSp0-M5bIFEa3I2zpUiQ61Uq0LpLUOftWt0CGoKlRtsJE2b20kB3TQ1A_s - SHA-384
    /// Pn_lMGae7Y4TtIxG0uvHL6KkHkcipVLGKgwb_ziuOMMh8OIIwctvG3SWSBZYsI8jDIrazqhYCrUIwadYqyoziA - SHA-512
    static let disclosure3 = "WyJ0ZXN0X3NhbHRfMyIsICJ0ZXN0X2tleV8zIiwgInRlc3RfdmFsdWVfMyJd"

    // MARK: Private

    private static let sha384JWS = "eyJhbGciOiJFUzUxMiIsInR5cCI6ImZsYXQifQ.eyJfc2QiOlsib3VMV3pzSC0td1lOWFZCMXFQRGozLU1Ma21JMEp3Yk52bXV6ejFSSE16Y0Y0dXQ1UDAzd2F1WUNxdEVieW5vdSIsIkNfd2hDRVFHY2Y5M19yVmFYZ1I0Ulp1dWpDWDBCOW05ZzBFQTUyU2VKUjZBbTc0cGYzT193elV6alNDSS0wdmEiLCJ2MDNlOEdSU3AwLU01YklGRWEzSTJ6cFVpUTYxVXEwTHBMVU9mdFd0MENHb0tsUnRzSkUyYjIwa0IzVFExQV9zIl0sIl9zZF9hbGciOiJzaGEtMzg0In0.Acv6TXARNRkyxxvkhkYtgDgsFUdxMsQ-_zAxIMHjAWAMAhh4hEDk52a0vKu2ZU5ZDK_zppQWlGMyN_hParB0dfLTAFVC94yO5jlAeA72BlSlyZUHci_gWSchW0S6GF2Vn938u8YWvUwH5RTqOEDPau7R7iNUcttKtI1yw1IagfkhLlHX"

    private static let sha512JWS = "eyJhbGciOiJFUzUxMiIsInR5cCI6ImZsYXQifQ.eyJfc2QiOlsiaC1ocVpCS3FKTE9jU3JEampZejh2ajM0eDljTHJFZzNERHY3ZGtGczNDUDBPZ3RtVS1jcGtJbkNPYWE0VFNBT296eXM0TFVvdXctalBtTkstM0t6bFEiLCJnWVpwWGdGdE9xMXRGTTVRaktCWW9jb1hMdDA3cmhHU0RoWWJWZkM1UmF2dUJ6aVdnUGRJYkUwc1pkclBtLXAzcmhBMmlkMVFodUJnWFE4N1pjV1dMZyIsIlBuX2xNR2FlN1k0VHRJeEcwdXZITDZLa0hrY2lwVkxHS2d3Yl96aXVPTU1oOE9JSXdjdHZHM1NXU0JaWXNJOGpESXJhenFoWUNyVUl3YWRZcXlvemlBIl0sIl9zZF9hbGciOiJzaGEtNTEyIn0.ASVFjHR64yl44JtgGNEe_wK6vnZ2fHpCgQIlCzyG5dIUYX7OqKIVPasQpTion9pFadiwNrEuXeVttnJwYpSra7s8AA8zYU-1q_j7kcw3DxjhJ_FnUG7VADgEgu4zsOK7yUoyXzAMeCeW-CgtI6MNX-LU0rrwgWixioCtKPg2bljdymSS"
  }
}

extension FlatJWT {
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
