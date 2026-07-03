import BITSwiyuSharedKMP
import Foundation
import Testing
@testable import BITCore
@testable import BITNonCompliance

struct HeidiUtilValueStringTests {

  @Test
  func jsonString_string_returnsString() {
    let result = Heidi_utilValue.String(v1: "value").jsonString()

    #expect(result == "value")
  }

  @Test
  func jsonString_integer_returnsString() {
    let result = Heidi_utilValue.Number(v1: Heidi_utilJsonNumber.Integer(v1: 1)).jsonString()

    #expect(result == "1")
  }

  @Test
  func jsonString_float_returnsString() {
    let result = Heidi_utilValue.Number(v1: Heidi_utilJsonNumber.Float(v1: 1.1)).jsonString()

    #expect(result == "1.1")
  }

  @Test(arguments: [false, true])
  func jsonString_bool_returnsString(boolean: Bool) {
    let result = Heidi_utilValue.Boolean(v1: boolean).jsonString()

    #expect(result == String(boolean))
  }

  @Test
  func jsonString_null_returnsString() {
    let result = Heidi_utilValue.Null().jsonString()

    #expect(result == "null")
  }

  @Test
  func jsonString_bytes_returnsString() throws {
    let bytes = KotlinByteArray(size: 1)
    let result = Heidi_utilValue.Bytes(v1: bytes).jsonString()

    #expect(try Data(base64Encoded: result.asData(), options: [.ignoreUnknownCharacters]) == Data(count: 1))
  }

  @Test
  func jsonString_array_returnsString() {
    let result = Heidi_utilValue.Array(v1: [Heidi_utilValue.String(v1: "one"), Heidi_utilValue.Null()]).jsonString()

    #expect(result == "[\"one\",\"null\"]")
  }

  @Test
  func jsonString_object_returnsString() {
    let result = Heidi_utilValue.Object(v1: ["test": Heidi_utilValue.String(v1: "one")]).jsonString()

    #expect(result == "{\"test\":\"one\"}")
  }
}
