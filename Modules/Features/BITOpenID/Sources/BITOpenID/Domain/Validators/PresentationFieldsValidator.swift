import BITAnyCredentialFormat
import BITCore
import Factory
import Sextant

// MARK: - PresentationFieldsValidatorError

enum PresentationFieldsValidatorError: Error {
  case missingRequiredField
}

// MARK: - PresentationFieldsValidator

struct PresentationFieldsValidator: PresentationFieldsValidatorProtocol {

  // MARK: Internal

  func validate(_ anyCredential: AnyCredential, with requestedFields: [Field]) throws -> [PresentationField] {
    guard let json = try? anyCredentialJsonGenerator.generate(for: anyCredential) else { return [] }
    return try requestedFields.compactMap { field -> PresentationField? in
      try resolvePresentationField(field, json: json)
    }
  }

  // MARK: Private

  @Injected(\.anyCredentialJsonGenerator) private var anyCredentialJsonGenerator: AnyCredentialJsonGeneratorProtocol

  private func resolvePresentationField(_ field: Field, json: String) throws -> PresentationField? {
    guard !field.path.isEmpty else { return nil }
    for path in field.path {
      guard let value = try getMatchingValue(json: json, path: path, field: field) else { continue }
      return PresentationField(jsonPath: path, value: value)
    }
    throw PresentationFieldsValidatorError.missingRequiredField
  }

  private func getMatchingValue(json: String, path: String, field: Field) throws -> CodableValue? {
    guard
      let values = json.query(values: path),
      let value = values.first as Any?
    else {
      return nil
    }
    guard field.isMatching(value) else { throw PresentationFieldsValidatorError.missingRequiredField }
    return (try? CodableValue(anyValue: value)) ?? CodableValue(value: String(describing: value), as: "string")
  }

}
