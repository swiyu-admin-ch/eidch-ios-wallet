import Foundation
import XCTest
@testable import BITClaimsPathPointer
@testable import BITCore
@testable import BITSdJWT

extension FlatSimpleArrayJWT {

  func assertIn(_ json: JSON) {
    if let testValue1 {
      XCTAssertEqual(json.count, 2)
      XCTAssertEqual(json[FlatSimpleArrayJWT.CodingKeys.testValue1.rawValue] as? String, testValue1)
    } else {
      XCTAssertEqual(json.count, 1)
    }
    XCTAssertEqual(json[FlatSimpleArrayJWT.CodingKeys.array.rawValue] as? [String], array.elements)
  }
}

extension SdJWS<FlatSimpleArrayJWT> {
  func assertDisclosures(hasOtherClaims: Bool) {
    XCTAssertEqual(disclosures.count, 2)
    if hasOtherClaims {
      disclosures.assertContains(FlatSimpleArrayJWT.value1Path, rawDisclosure: FlatSimpleArrayJWT.Mock.disclosure1)
    } else {
      disclosures.assertContains(FlatSimpleArrayJWT.element1Path, rawDisclosure: FlatSimpleArrayJWT.Mock.disclosureElement1)
    }
    disclosures.assertContains(FlatSimpleArrayJWT.element2Path, rawDisclosure: FlatSimpleArrayJWT.Mock.disclosureElement2)
  }
}

extension FlatSimpleArrayJWT {
  static var value1Path: ClaimsPathPointer {
    [.string(FlatSimpleArrayJWT.CodingKeys.testValue1.rawValue)]
  }

  static var element1Path: ClaimsPathPointer {
    [.string(FlatSimpleArrayJWT.CodingKeys.array.rawValue), .index(0)]
  }

  static var element2Path: ClaimsPathPointer {
    [.string(FlatSimpleArrayJWT.CodingKeys.array.rawValue), .index(1)]
  }
}
