import BITCrypto
import Factory
import Foundation
import Spyable

// MARK: - VcSchemaServiceError

enum VcSchemaServiceError: Error {
  case invalidVcSchema
}

// MARK: - VcSchemaServiceProtocol

@Spyable
public protocol VcSchemaServiceProtocol {
  func fetch(for typeMetadata: TypeMetadata) async throws -> VcSchema?
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

  // MARK: Private

  @Injected(\.sriValidator) private var sriValidator: SRIValidatorProtocol
  @Injected(\.openIDRepository) private var repository: OpenIDRepositoryProtocol

}
