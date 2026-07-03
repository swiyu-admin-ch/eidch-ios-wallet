// swiftlint: disable force_cast
import Foundation
import XCTest
@testable import BITClaimsPathPointer
@testable import BITCore
@testable import BITSdJWT

extension FlatObjectArrayJWT {

  func assertIn(_ json: JSON) {
    XCTAssertEqual(json.count, 1)
    let jsonArray = json[FlatObjectArrayJWT.CodingKeys.array.rawValue] as! [JSON]

    XCTAssertEqual(jsonArray.count, 2)
    XCTAssertEqual(jsonArray[0][FlatObjectArrayJWT.Nested.CodingKeys.testKey1.rawValue] as? String, array[0].testKey1)
    XCTAssertEqual(jsonArray[0][FlatObjectArrayJWT.Nested.CodingKeys.testKey2.rawValue] as? String, array[0].testKey2)

    XCTAssertEqual(jsonArray[1][FlatObjectArrayJWT.Nested.CodingKeys.testKey1.rawValue] as? String, array[1].testKey1)
    XCTAssertEqual(jsonArray[1][FlatObjectArrayJWT.Nested.CodingKeys.testKey2.rawValue] as? String, array[1].testKey2)
  }
}

extension SdJWS<FlatObjectArrayJWT> {
  func assertDisclosures(fullyDisclosed: Bool) {
    XCTAssertEqual(disclosures.count, fullyDisclosed ? 2 : 1)
    if fullyDisclosed {
      disclosures.assertContains([FlatObjectArrayJWT.element1Path, FlatObjectArrayJWT.nestedElementPath_1_1, FlatObjectArrayJWT.nestedElementPath_1_2], rawDisclosure: FlatObjectArrayJWT.Mock.disclosureElement1)
    }
    disclosures.assertContains([FlatObjectArrayJWT.element2Path, FlatObjectArrayJWT.nestedElementPath_2_1, FlatObjectArrayJWT.nestedElementPath_2_2], rawDisclosure: FlatObjectArrayJWT.Mock.disclosureElement2)
  }
}

extension FlatObjectArrayJWT {
  static var element1Path: ClaimsPathPointer {
    [.string(FlatObjectArrayJWT.CodingKeys.array.rawValue), .index(0)]
  }

  static var nestedElementPath_1_1: ClaimsPathPointer {
    [.string(FlatObjectArrayJWT.CodingKeys.array.rawValue), .index(0), .string(Nested.CodingKeys.testKey1.rawValue)]
  }

  static var nestedElementPath_1_2: ClaimsPathPointer {
    [.string(FlatObjectArrayJWT.CodingKeys.array.rawValue), .index(0), .string(Nested.CodingKeys.testKey2.rawValue)]
  }

  static var element2Path: ClaimsPathPointer {
    [.string(FlatObjectArrayJWT.CodingKeys.array.rawValue), .index(1)]
  }

  static var nestedElementPath_2_1: ClaimsPathPointer {
    [.string(FlatObjectArrayJWT.CodingKeys.array.rawValue), .index(1), .string(Nested.CodingKeys.testKey1.rawValue)]
  }

  static var nestedElementPath_2_2: ClaimsPathPointer {
    [.string(FlatObjectArrayJWT.CodingKeys.array.rawValue), .index(1), .string(Nested.CodingKeys.testKey2.rawValue)]
  }
}
