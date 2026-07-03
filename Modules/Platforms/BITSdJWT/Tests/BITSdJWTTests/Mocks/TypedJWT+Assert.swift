import Foundation
import XCTest
@testable import BITClaimsPathPointer
@testable import BITCore
@testable import BITSdJWT

extension TypedJWT {
  func assertIn(_ json: JSON) {
    XCTAssertEqual(json.count, 3)
    XCTAssertEqual(json[TypedJWT.CodingKeys.number.rawValue] as? Int, number)
    XCTAssertEqual(json[TypedJWT.CodingKeys.boolean.rawValue] as? Bool, boolean)
    XCTAssertNil(json[TypedJWT.CodingKeys.null.rawValue] as? Int)
  }
}

extension SdJWS<TypedJWT> {
  func assertDisclosures() {
    XCTAssertEqual(disclosures.count, 3)
    disclosures.assertContains([.string(TypedJWT.CodingKeys.number.rawValue)], rawDisclosure: TypedJWT.Mock.numberDisclosure)
    disclosures.assertContains([.string(TypedJWT.CodingKeys.boolean.rawValue)], rawDisclosure: TypedJWT.Mock.booleanDisclosure)
    disclosures.assertContains([.string(TypedJWT.CodingKeys.null.rawValue)], rawDisclosure: TypedJWT.Mock.nullDisclosure)
  }
}
