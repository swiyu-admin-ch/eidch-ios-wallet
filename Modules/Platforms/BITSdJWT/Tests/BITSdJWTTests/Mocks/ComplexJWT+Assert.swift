// swiftlint: disable force_cast
import Foundation
import XCTest
@testable import BITClaimsPathPointer
@testable import BITCore
@testable import BITSdJWT

extension ComplexJWT {

  func assertIn(_ json: JSON) {
    XCTAssertEqual(json.count, 8)
    XCTAssertEqual(json[ComplexJWT.CodingKeys.undisclosed.rawValue] as! String, undisclosed)
    XCTAssertEqual(json[ComplexJWT.CodingKeys.flat.rawValue] as? String, flat)
    XCTAssertEqual(json[ComplexJWT.CodingKeys.flatArray.rawValue] as? [String], flatArray)

    let flatObjectJson = json[ComplexJWT.CodingKeys.flatObject.rawValue] as! JSON
    XCTAssertEqual(flatObjectJson.count, 2)
    XCTAssertEqual(flatObjectJson[ComplexJWT.NestedObject.CodingKeys.key1.rawValue] as? String, flatObject?.key1)
    XCTAssertEqual(flatObjectJson[ComplexJWT.NestedObject.CodingKeys.key2.rawValue] as? String, flatObject?.key2)

    XCTAssertEqual(json[ComplexJWT.CodingKeys.undisclosedArray.rawValue] as! [String], undisclosedArray)
    XCTAssertEqual(json[ComplexJWT.CodingKeys.partlyDisclosedArray.rawValue] as! [String], partlyDisclosedArray.elements)

    let undisclosedObjectJson = json[ComplexJWT.CodingKeys.undisclosedObject.rawValue] as! JSON
    XCTAssertEqual(undisclosedObjectJson.count, 2)
    XCTAssertEqual(undisclosedObjectJson[ComplexJWT.NestedObject.CodingKeys.key1.rawValue] as? String, undisclosedObject.key1)
    XCTAssertEqual(undisclosedObjectJson[ComplexJWT.NestedObject.CodingKeys.key2.rawValue] as? String, undisclosedObject.key2)

    let partlyDisclosedObjectJson = json[ComplexJWT.CodingKeys.partlyDisclosedObject.rawValue] as! JSON
    XCTAssertEqual(partlyDisclosedObjectJson.count, 3)
    XCTAssertEqual(partlyDisclosedObjectJson[ComplexJWT.PartlyDisclosedObject.CodingKeys.key1.rawValue] as? String, partlyDisclosedObject.key1)

    let json1_2 = partlyDisclosedObjectJson[ComplexJWT.PartlyDisclosedObject.CodingKeys.key2.rawValue] as! JSON
    XCTAssertEqual(json1_2.count, 3)
    XCTAssertEqual(json1_2[ComplexJWT.PartlyDisclosedObject12.CodingKeys.key1.rawValue] as? String, partlyDisclosedObject.key2?.key1)
    XCTAssertEqual(json1_2[ComplexJWT.PartlyDisclosedObject12.CodingKeys.key2.rawValue] as? String, partlyDisclosedObject.key2?.key2)

    let arrayJson1_2_3 = json1_2[ComplexJWT.PartlyDisclosedObject12.CodingKeys.key3.rawValue] as! [JSON]
    XCTAssertEqual(arrayJson1_2_3.count, 2)
    XCTAssertEqual(arrayJson1_2_3[0][ComplexJWT.PartlyDisclosedObject123.CodingKeys.key.rawValue] as? [String], partlyDisclosedObject.key2?.key3.elements[0].key.elements)
    XCTAssertEqual(arrayJson1_2_3[1][ComplexJWT.PartlyDisclosedObject123.CodingKeys.key.rawValue] as? [String], partlyDisclosedObject.key2?.key3.elements[1].key.elements)

    XCTAssertEqual(partlyDisclosedObjectJson[ComplexJWT.PartlyDisclosedObject.CodingKeys.key3.rawValue] as? [String], partlyDisclosedObject.key3)
  }
}

extension SdJWS<ComplexJWT> {
  func assertDisclosures() {
    XCTAssertEqual(disclosures.count, 15)

    disclosures.assertContains(ComplexJWT.flatPath, rawDisclosure: ComplexJWT.Mock.flatDisclosure)
    disclosures.assertContains([ComplexJWT.flatArrayPath, ComplexJWT.flatArrayElement1Path, ComplexJWT.flatArrayElement2Path], rawDisclosure: ComplexJWT.Mock.flatArrayDisclosure)
    disclosures.assertContains([ComplexJWT.flatObjectPath, ComplexJWT.flatObjectElement1Path, ComplexJWT.flatObjectElement2Path], rawDisclosure: ComplexJWT.Mock.flatObjectDisclosure)

    disclosures.assertContains(ComplexJWT.partlyDisclosedArrayPath + [.index(0)], rawDisclosure: ComplexJWT.Mock.arrayPartlyDisclosedDisclosure1)
    disclosures.assertContains(ComplexJWT.partlyDisclosedArrayPath + [.index(2)], rawDisclosure: ComplexJWT.Mock.arrayPartlyDisclosedDisclosure3)

    disclosures.assertContains([ComplexJWT.PartlyDisclosedObject.key2Path, ComplexJWT.PartlyDisclosedObject12.key2Path], rawDisclosure: ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_2)
    disclosures.assertContains(ComplexJWT.PartlyDisclosedObject12.key1Path, rawDisclosure: ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_2_1)
    disclosures.assertContains(ComplexJWT.PartlyDisclosedObject12.key3Path + [.null], rawDisclosure: ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_2_3)

    disclosures.assertContains([ComplexJWT.PartlyDisclosedObject12.key3Path + [.index(0)], ComplexJWT.PartlyDisclosedObject123.getKeyPath(index: 0) + [.null], ComplexJWT.PartlyDisclosedObject123.getKeyPath(index: 0) + [.index(0)]], rawDisclosure: ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_2_3_1)
    disclosures.assertContains(ComplexJWT.PartlyDisclosedObject12.key3Path + [.index(1)], rawDisclosure: ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_2_3_2)
    disclosures.assertContains(ComplexJWT.PartlyDisclosedObject123.getKeyPath(index: 1) + [ .null], rawDisclosure: ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_2_3_2_1)

    disclosures.assertContains(ComplexJWT.PartlyDisclosedObject123.getKeyPath(index: 1) + [.index(0)], rawDisclosure: ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_2_3_2_1_1)

    disclosures.assertContains(ComplexJWT.PartlyDisclosedObject.key3Path + [.null], rawDisclosure: ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_3)
    disclosures.assertContains(ComplexJWT.PartlyDisclosedObject.key3Path + [.index(0)], rawDisclosure: ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_3_1)
    disclosures.assertContains(ComplexJWT.PartlyDisclosedObject.key3Path + [.index(1)], rawDisclosure: ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_3_2)
  }
}

extension ComplexJWT {
  static var flatPath: ClaimsPathPointer {
    [.string(CodingKeys.flat.rawValue)]
  }

  static var flatArrayPath: ClaimsPathPointer {
    [.string(CodingKeys.flatArray.rawValue), .null]
  }

  static var flatArrayElement1Path: ClaimsPathPointer {
    [.string(CodingKeys.flatArray.rawValue), .index(0)]
  }

  static var flatArrayElement2Path: ClaimsPathPointer {
    [.string(CodingKeys.flatArray.rawValue), .index(1)]
  }

  static var flatObjectPath: ClaimsPathPointer {
    [.string(CodingKeys.flatObject.rawValue)]
  }

  static var flatObjectElement1Path: ClaimsPathPointer {
    [.string(CodingKeys.flatObject.rawValue), .string(NestedObject.CodingKeys.key1.rawValue)]
  }

  static var flatObjectElement2Path: ClaimsPathPointer {
    [.string(CodingKeys.flatObject.rawValue), .string(NestedObject.CodingKeys.key2.rawValue)]
  }

  static var partlyDisclosedArrayPath: ClaimsPathPointer {
    [.string(CodingKeys.partlyDisclosedArray.rawValue)]
  }

  static var partlyDisclosedObjectPath: ClaimsPathPointer {
    [.string(CodingKeys.partlyDisclosedObject.rawValue)]
  }
}

extension ComplexJWT.PartlyDisclosedObject {
  static var key1Path: ClaimsPathPointer {
    ComplexJWT.partlyDisclosedObjectPath + [.string(CodingKeys.key1.rawValue)]
  }

  static var key2Path: ClaimsPathPointer {
    ComplexJWT.partlyDisclosedObjectPath + [.string(CodingKeys.key2.rawValue)]
  }

  static var key3Path: ClaimsPathPointer {
    ComplexJWT.partlyDisclosedObjectPath + [.string(CodingKeys.key3.rawValue)]
  }
}

extension ComplexJWT.PartlyDisclosedObject12 {
  static var key1Path: ClaimsPathPointer {
    ComplexJWT.PartlyDisclosedObject.key2Path + [.string(CodingKeys.key1.rawValue)]
  }

  static var key2Path: ClaimsPathPointer {
    ComplexJWT.PartlyDisclosedObject.key2Path + [.string(CodingKeys.key2.rawValue)]
  }

  static var key3Path: ClaimsPathPointer {
    ComplexJWT.PartlyDisclosedObject.key2Path + [.string(CodingKeys.key3.rawValue)]
  }
}

extension ComplexJWT.PartlyDisclosedObject123 {
  static func getKeyPath(index: Int) -> ClaimsPathPointer {
    ComplexJWT.PartlyDisclosedObject12.key3Path + [.index(index), .string(CodingKeys.key.rawValue)]
  }
}
