#if DEBUG
import Foundation

// MARK: - JsonSchemaMock

struct JsonSchemaMock: Encodable {

  struct Property: Encodable {
    var type: String
    var pattern: String?
  }

  var schema = "https://json-schema.org/draft/2020-12/schema"
  var type = "object"
  var properties: [String: Property]
  var required = [String]()

  var data: Data {
    (try? JSONEncoder().encode(self)) ?? Data()
  }

  private enum CodingKeys: String, CodingKey {
    case schema = "$schema"
    case type, properties, required
  }
}

extension JsonSchemaMock {
  static let withRegularExpression = JsonSchemaMock(
    properties: [
      "vct": Property(type: "string", pattern: "^^((x+x+x+)+)*y$"),
      "iss": Property(type: "string"),
    ],
    required: ["iss", "vct"])
}

#endif
