import Foundation
import XCTest
@testable import BITClaimsPathPointer
@testable import BITSdJWT

extension [SdJWTDisclosure] {
  func assertContains(_ path: ClaimsPathPointer, rawDisclosure: String) {
    let disclosure = first { $0.disclosure == rawDisclosure }
    XCTAssertEqual(disclosure?.paths, [path], "Disclosure: \(rawDisclosure)")
  }

  func assertContains(_ paths: [ClaimsPathPointer], rawDisclosure: String) {
    let disclosure = first { $0.disclosure == rawDisclosure }
    XCTAssertEqual(Set(disclosure?.paths ?? []), Set(paths), "Disclosure: \(rawDisclosure)")
  }
}
