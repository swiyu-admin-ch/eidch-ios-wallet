import BITCrypto
import BITSdJWT
import Factory
import Spyable

// MARK: - VcSchemaServiceError

enum VcSchemaServiceError: Error {
  case invalidVcSchema
}

// MARK: - VcSchemaServiceProtocol

@Spyable
public protocol VcSchemaServiceProtocol {
  func fetch(for typeMetadata: TypeMetadata) async throws -> VcSchema?
  func validate(_ vcSchema: VcSchema, with vcSdJwt: VcSdJwt) -> Bool
}

// MARK: - VcSchemaService

struct VcSchemaService: VcSchemaServiceProtocol {

  // MARK: Internal

  func fetch(for typeMetadata: TypeMetadata) async throws -> VcSchema? {
    guard let schemaUrl = typeMetadata.schemaUrl else {
      return nil
    }

    let vcSchema = try await repository.fetchVcSchemaData(from: schemaUrl)

    guard let schemaIntegrity = typeMetadata.schemaIntegrity else {
      return vcSchema
    }

    guard try sriValidator.validate(vcSchema, with: schemaIntegrity) else {
      throw VcSchemaServiceError.invalidVcSchema
    }

    return vcSchema
  }

  func validate(_ vcSchema: VcSchema, with vcSdJwt: VcSdJwt) -> Bool {
    do {
      guard let data = vcSdJwt.rawPayload.data(using: .utf8) else {
        return false
      }

      return try jsonSchemaValidator.validate(data, with: vcSchema)
    } catch {
      return false
    }
  }

  // MARK: Private

  @Injected(\.sriValidator) private var sriValidator: SRIValidatorProtocol
  @Injected(\.jsonSchemaValidator) private var jsonSchemaValidator: JsonSchema
  @Injected(\.openIDRepository) private var repository: OpenIDRepositoryProtocol

}
