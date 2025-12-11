import BITAnyCredentialFormat
import BITJWT
import BITOca
import BITSdJWT
import Factory
import Foundation
import Spyable

// MARK: - FetchVcMetadataForCredentialUseCaseProtocol

@Spyable
public protocol FetchVcMetadataForCredentialUseCaseProtocol {
  func execute(anyCredential: AnyCredential) async throws -> (VcSchema?, RawOcaBundle?)
  func execute(metadata: any CredentialMetadata.AnyCredentialConfigurationSupported) async throws -> (VcSchema?, RawOcaBundle?)
}

// MARK: - FetchVcMetadataForVcSdJwtUseCase

struct FetchVcMetadataForVcSdJwtUseCase: FetchVcMetadataForCredentialUseCaseProtocol {

  // MARK: Internal

  func execute(anyCredential: AnyCredential) async throws -> (VcSchema?, RawOcaBundle?) {
    guard let vcSdJwt = anyCredential as? VcSdJwt else { throw CredentialFormatError.formatNotSupported }
    return try await fetchMetadata(from: vcSdJwt.payload.typeMetadataUri, vct: vcSdJwt.payload.vct)
  }

  func execute(metadata: any CredentialMetadata.AnyCredentialConfigurationSupported) async throws -> (VcSchema?, RawOcaBundle?) {
    guard let vcSdJwtMetadata = metadata as? CredentialMetadata.VcSdJwtCredentialConfigurationSupported else { throw CredentialFormatError.formatNotSupported }
    return try await fetchMetadata(from: vcSdJwtMetadata.typeMetadataUri, vct: vcSdJwtMetadata.vct)
  }

  // MARK: Private

  @Injected(\.vcSchemaService) private var vcSchemaService: VcSchemaServiceProtocol
  @Injected(\.vcSdJwtSchemaValidator) private var vcSdJwtSchemaValidator: VcSdJwtSchemaValidatorProtocol
  @Injected(\.typeMetadataService) private var typeMetadataService: TypeMetadataServiceProtocol
  @Injected(\.ocaBundleService) private var ocaBundleService: OCABundleServiceProtocol

  private func fetchMetadata(from uri: TypeMetadataUri?, vct: String) async throws -> (VcSchema?, RawOcaBundle?) {
    guard
      let uri,
      let typeMetadata = try await typeMetadataService.fetch(from: uri, vct: vct)
    else { return (nil, nil) }
    let vcSchema = try await vcSchemaService.fetch(for: typeMetadata)
    if let vcSchema {
      guard try vcSdJwtSchemaValidator.validate(schema: vcSchema) else {
        throw FetchAnyVerifiableCredentialError.invalidVcSchema
      }
    }
    let rawOcaBundle = try await fetchOCABundle(from: typeMetadata)
    return (vcSchema, rawOcaBundle)
  }

  private func fetchOCABundle(from typeMetadata: TypeMetadata) async throws -> RawOcaBundle? {
    guard
      let oca = typeMetadata.displays?.first(where: { $0.rendering?.oca != nil })?.rendering?.oca, // OCA localization is not taken in consideration in the display: we take the first one available
      let ocaBundle = try await ocaBundleService.fetchVcSdJwtOcaBundle(from: oca)
    else {
      return nil
    }

    return ocaBundle
  }

}
