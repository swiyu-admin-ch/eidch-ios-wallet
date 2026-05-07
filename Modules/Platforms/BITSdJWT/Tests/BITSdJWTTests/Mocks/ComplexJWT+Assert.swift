// swiftlint: disable force_cast
import Foundation
import XCTest
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
