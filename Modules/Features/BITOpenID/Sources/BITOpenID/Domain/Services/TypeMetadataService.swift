import BITCrypto
import BITSdJWT
import Factory
import Foundation
import Spyable

// MARK: - TypeMetadataServiceError

enum TypeMetadataServiceError: Error {
  case vctMismatch
  case missingVctIntegrity
  case typeMetadataInvalidIntegrity
}

// MARK: - TypeMetadataServiceProtocol

@Spyable
public protocol TypeMetadataServiceProtocol {
  ///
  /// Fetches the type metadata based on the `vct` property of a `vc`.
  ///
  /// Returns:
  /// - The fetched `TypeMetadata` if available, or `nil` if `vc.vct` does not exist or is not a valid URL.
  ///
  /// Throws:
  /// - `RepositoryError` if the network request fails.
  /// - `TypeMetadataServiceError.vctMismatch` if the `vct` doesn't match between the `vc` and `TypeMetadata`.
  /// - `TypeMetadataServiceError.missingVctIntegrity` if `vc.vctIntegrity` is not available but `vc.vct` is present.
  /// - `TypeMetadataServiceError.typeMetadataInvalidIntegrity` if the `SRI` validator fails to validate integrity.
  ///
  func fetch(_ vc: VcSdJwtPayload) async throws -> TypeMetadata?
}

// MARK: - TypeMetadataService

struct TypeMetadataService: TypeMetadataServiceProtocol {

  // MARK: Internal

  func fetch(_ vc: VcSdJwtPayload) async throws -> TypeMetadata? {
    guard let url = URL(string: vc.vct), url.isValidHttpUrl else {
      return nil
    }

    let (typeMetadata, data) = try await repository.fetchTypeMetadata(from: url)

    guard vc.vct == typeMetadata.vct else {
      throw TypeMetadataServiceError.vctMismatch
    }

    guard let vctIntegrity = vc.vctIntegrity else {
      throw TypeMetadataServiceError.missingVctIntegrity
    }

    do {
      guard try sriValidator.validate(data, with: vctIntegrity) else {
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
