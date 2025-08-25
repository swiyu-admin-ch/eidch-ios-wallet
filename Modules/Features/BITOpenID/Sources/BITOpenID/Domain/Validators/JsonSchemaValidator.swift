import Foundation
import JsonSchemaValidatorSources
import Spyable

// MARK: - JsonSchemaValidator

struct JsonSchemaValidator: JsonSchemaValidatorProtocol {
  func validate(jsonObject: Data, with jsonSchema: Data) throws -> Bool {
    guard
      let jsonInstanceString = String(data: jsonObject, encoding: .utf8),
      let schemaString = String(data: jsonSchema, encoding: .utf8) else { return false }

    return try Validator(schema: schemaString).isValid(instance: jsonInstanceString)
  }

  func validate(dictionary: [String: Any?], with jsonSchema: Data) throws -> Bool {
    let jsonData = try JSONSerialization.data(withJSONObject: dictionary)
    guard
      let jsonString = String(data: jsonData, encoding: .utf8),
      let schemaString = String(data: jsonSchema, encoding: .utf8) else { return false }

    return try Validator(schema: schemaString).isValid(instance: jsonString)
  }
}

// MARK: - JsonSchemaValidatorProtocol

/// Providing functionality for working with JSON Schemas
/// https://json-schema.org/draft/2020-12/release-notes
@Spyable
public protocol JsonSchemaValidatorProtocol {

  /// Validates the provided JSON object against the given JSON Schema
  ///
  /// - Parameters:
  ///   - jsonObject: The JSON object to be validated.
  ///   - jsonSchema: The raw JSON schema to be used for validation.
  ///
  /// - Returns: `true` if the JSON object is valid according to the schema;
  ///             otherwise `false`.
  func validate(jsonObject: Data, with jsonSchema: Data) throws -> Bool

  /// Validates the provided JSON object against the given JSON Schema
  ///
  /// - Parameters:
  ///   - dicationary: The JSON object to be validated.
  ///   - jsonSchema: The raw JSON schema to be used for validation.
  ///
  /// - Returns: `true` if the JSON object is valid according to the schema;
  ///             otherwise `false`.
  func validate(dictionary: [String: Any?], with jsonSchema: Data) throws -> Bool
}
