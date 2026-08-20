import BITAnyCredentialFormat
import BITOca
import Factory
import Foundation
import Spyable

// MARK: - FetchVcMetadataUseCaseProtocol

@Spyable
public protocol FetchVcMetadataUseCaseProtocol {
  func execute(anyCredential: AnyCredential) async throws -> RawOcaBundle?
  func execute(metadata: any CredentialIssuerMetadata.AnyCredentialConfigurationSupported) async throws -> RawOcaBundle?
}

// MARK: - FetchVcMetadataUseCase

struct FetchVcMetadataUseCase: FetchVcMetadataUseCaseProtocol {

  // MARK: Internal

  func execute(anyCredential: AnyCredential) async throws -> RawOcaBundle? {
    guard let dispatcherFormat = dispatcher[anyCredential.format] else {
      throw CredentialFormatError.formatNotSupported
    }

    let (vcSchema, rawOcaBundle) = try await dispatcherFormat.execute(anyCredential: anyCredential)

    if let vcSchema {
      let claims = anyCredential.getClaimsJSON(.all)
      guard try jsonSchemaValidator.validate(json: claims, with: vcSchema) else {
        throw FetchAnyVerifiableCredentialError.invalidVcSchema
      }
    }
    return rawOcaBundle
  }

  func execute(metadata: any CredentialIssuerMetadata.AnyCredentialConfigurationSupported) async throws -> RawOcaBundle? {
    guard let dispatcherFormat = dispatcher[metadata.format] else {
      throw CredentialFormatError.formatNotSupported
    }

    let (_, rawOcaBundle) = try await dispatcherFormat.execute(metadata: metadata)

    return rawOcaBundle
  }

  // MARK: Private

  @Injected(\.fetchVcMetadataForAnyCredentialDispatcher) private var dispatcher: [CredentialFormat: FetchVcMetadataForCredentialUseCaseProtocol]
  @Injected(\.jsonSchemaValidator) private var jsonSchemaValidator: JsonSchemaValidatorProtocol
}
