import BITCrypto
import BITSdJWT
import Factory
import Foundation
import Spyable

// MARK: - TypeMetadataServiceError

enum TypeMetadataServiceError: Error {
  case vctMismatch
  case typeMetadataInvalidIntegrity
}

// MARK: - TypeMetadataServiceProtocol

@Spyable
protocol TypeMetadataServiceProtocol {
  ///
  /// Fetches the type metadata based on the `vct_metadata_uri` or `vct` property of a `vc`.
  ///
  /// Returns:
  /// - The fetched `TypeMetadata` if available..
  ///
  /// Throws:
  /// - `RepositoryError` if the network request fails.
  /// - `TypeMetadataServiceError.vctMismatch` if the `vct` doesn't match between the `vc` and `TypeMetadata`.
  /// - `TypeMetadataServiceError.missingVctIntegrity` if `vc.vctIntegrity` is not available but `vc.vct` is present.
  /// - `TypeMetadataServiceError.typeMetadataInvalidIntegrity` if the `SRI` validator fails to validate integrity.
  ///
  func fetch(from uri: TypeMetadataUri, vct: String) async throws -> TypeMetadata?
}

// MARK: - TypeMetadataService

struct TypeMetadataService: TypeMetadataServiceProtocol {

  // MARK: Internal

  func fetch(from uri: TypeMetadataUri, vct: String) async throws -> TypeMetadata? {
    let response = try await repository.fetchTypeMetadata(from: uri.url)
    let typeMetadata = response.object

    guard vct == typeMetadata.vct else {
      throw TypeMetadataServiceError.vctMismatch
    }

    guard let integrity = uri.integrity else {
      return typeMetadata
    }

    do {
      guard try sriValidator.validate(response.data, with: integrity) else {
        throw TypeMetadataServiceError.typeMetadataInvalidIntegrity
      }
      return typeMetadata
    } catch {
      throw TypeMetadataServiceError.typeMetadataInvalidIntegrity
    }
  }

  // MARK: Private

  @Injected(\.sriValidator) private var sriValidator: SRIValidatorProtocol
  @Injected(\.openIDRepository) private var repository: OpenIDRepositoryProtocol
}
