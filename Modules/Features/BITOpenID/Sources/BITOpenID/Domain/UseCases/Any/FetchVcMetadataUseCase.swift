import BITAnyCredentialFormat
import BITOca
import Factory
import Foundation
import Spyable

// MARK: - FetchVcMetadataUseCaseProtocol

@Spyable
public protocol FetchVcMetadataUseCaseProtocol {
  func execute(anyCredential: AnyCredential) async throws -> RawOcaBundle?
  func execute(metadata: any CredentialMetadata.AnyCredentialConfigurationSupported) async throws -> RawOcaBundle?
}

// MARK: - FetchVcMetadataUseCase

struct FetchVcMetadataUseCase: FetchVcMetadataUseCaseProtocol {

  // MARK: Internal

  func execute(anyCredential: AnyCredential) async throws -> RawOcaBundle? {
    guard let credentialFormat = CredentialFormat(rawValue: anyCredential.format), let dispatcherFormat = dispatcher[credentialFormat] else {
      throw CredentialFormatError.formatNotSupported
    }

    let (vcSchema, rawOcaBundle) = try await dispatcherFormat.execute(anyCredential: anyCredential)

    if let vcSchema {
      let claims = anyCredential.getClaimsDictionary(.all)
      guard try jsonSchemaValidator.validate(dictionary: claims, with: vcSchema) else {
        throw FetchAnyVerifiableCredentialError.invalidVcSchema
      }
    }
    return rawOcaBundle
  }

  func execute(metadata: any CredentialMetadata.AnyCredentialConfigurationSupported) async throws -> RawOcaBundle? {
    guard let credentialFormat = CredentialFormat(rawValue: metadata.format), let dispatcherFormat = dispatcher[credentialFormat] else {
      throw CredentialFormatError.formatNotSupported
    }

    let (_, rawOcaBundle) = try await dispatcherFormat.execute(metadata: metadata)

    return rawOcaBundle
  }

  // MARK: Private

  @Injected(\.fetchVcMetadataForAnyCredentialDispatcher) private var dispatcher: [CredentialFormat: FetchVcMetadataForCredentialUseCaseProtocol]
  @Injected(\.jsonSchemaValidator) private var jsonSchemaValidator: JsonSchemaValidatorProtocol
}
