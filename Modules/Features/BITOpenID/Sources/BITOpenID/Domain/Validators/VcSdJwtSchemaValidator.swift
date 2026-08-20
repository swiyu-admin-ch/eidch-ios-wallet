import Factory
import Foundation
import Spyable

// MARK: - VcSdJwtSchemaValidatorProtocol

@Spyable
public protocol VcSdJwtSchemaValidatorProtocol {
  func validate(schema: Data) throws -> Bool
}

// MARK: - VcSdJwtSchemaValidator

struct VcSdJwtSchemaValidator: VcSdJwtSchemaValidatorProtocol {

  // MARK: Internal

  func validate(schema: Data) throws -> Bool {
    try !containsRegularExpression(schema)
      && conformsTo202012MetaSchema(schema)
      && conformsToVcSdJwtSchema(schema)
  }

  // MARK: Private

  /// JSON Schema keywords whose values are regular expressions. A malicious issuer could supply a pattern with
  /// backtracking, so schemas relying on them are rejected before any credential is validated against them.
  private static let regularExpressionKeywords: Set<String> = ["pattern", "patternProperties"]

  @Injected(\.jsonSchemaValidator) private var validator: JsonSchemaValidatorProtocol

  private static func containsRegularExpressionKeyword(in json: Any) -> Bool {
    switch json {
    case let object as [String: Any]:
      !regularExpressionKeywords.isDisjoint(with: object.keys)
        || object.values.contains(where: containsRegularExpressionKeyword(in:))
    case let array as [Any]:
      array.contains(where: containsRegularExpressionKeyword(in:))
    default:
      false
    }
  }

  private func conformsTo202012MetaSchema(_ schema: Data) throws -> Bool {
    let metaSchema = try loadSchema("json-meta-schema-202012")
    return try validator.validate(jsonObject: schema, with: metaSchema)
  }

  private func conformsToVcSdJwtSchema(_ schema: Data) throws -> Bool {
    let vcSdJwtSchema = try loadSchema("json-schema-vcSdJwt")
    return try validator.validate(jsonObject: schema, with: vcSdJwtSchema)
  }

  private func containsRegularExpression(_ schema: Data) throws -> Bool {
    try Self.containsRegularExpressionKeyword(in: JSONSerialization.jsonObject(with: schema))
  }

  private func loadSchema(_ name: String) throws -> Data {
    guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
      return Data()
    }
    return try Data(contentsOf: url)
  }

}
