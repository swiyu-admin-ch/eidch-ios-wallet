import Factory
import Foundation
import Spyable

// MARK: - VcSdJwtSchemaValidatorProtocol

@Spyable
public protocol VcSdJwtSchemaValidatorProtocol {
  func validate(_ claims: [String: Any], schema: Data) throws -> Bool
}

// MARK: - VcSdJwtSchemaValidator

public struct VcSdJwtSchemaValidator: VcSdJwtSchemaValidatorProtocol {

  // MARK: Public

  public func validate(_ claims: [String: Any], schema: Data) throws -> Bool {
    guard try conformsTo202012MetaSchema(schema) && conformsToVcSdJwtSchema(schema) else {
      return false
    }

    return try validator.validate(dictionary: claims, with: schema)
  }

  // MARK: Private

  @Injected(\.jsonSchemaValidator) private var validator: JsonSchemaValidatorProtocol

  private func conformsTo202012MetaSchema(_ schema: Data) throws -> Bool {
    let metaSchema = try loadSchema("json-meta-schema-202012")
    return try validator.validate(jsonObject: schema, with: metaSchema)
  }

  private func conformsToVcSdJwtSchema(_ schema: Data) throws -> Bool {
    let vcSdJwtSchema = try loadSchema("json-schema-vcSdJwt")
    return try validator.validate(jsonObject: schema, with: vcSdJwtSchema)
  }

  private func loadSchema(_ name: String) throws -> Data {
    guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
      return Data()
    }
    return try Data(contentsOf: url)
  }

}
