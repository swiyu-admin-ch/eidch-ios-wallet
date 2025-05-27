import BITAnyCredentialFormat
import BITOca
import Factory
import Foundation
import Spyable

// MARK: - FetchVcMetadataUseCaseProtocol

@Spyable
public protocol FetchVcMetadataUseCaseProtocol {
  func execute(for anyCredential: AnyCredential) async throws -> OcaBundle?
}

// MARK: - FetchVcMetadataUseCase

struct FetchVcMetadataUseCase: FetchVcMetadataUseCaseProtocol {

  // MARK: Internal

  func execute(for anyCredential: AnyCredential) async throws -> OcaBundle? {
    guard let credentialFormat = CredentialFormat(rawValue: anyCredential.format), let dispatcherFormat = dispatcher[credentialFormat] else {
      throw CredentialFormatError.formatNotSupported
    }

    let (vcSchema, rawOcaBundle) = try await dispatcherFormat.execute(for: anyCredential)

    if let vcSchema {
      let claims = anyCredential.getClaimsDictionary(.all)
      guard try jsonSchemaValidator.validate(dictionary: claims, with: vcSchema) else {
        throw FetchAnyVerifiableCredentialError.invalidVcSchema
      }
    }
    guard let rawOcaBundle else { return nil }
    return try ocaBundler.createOcaBundle(rawOcaBundle)
  }

  // MARK: Private

  @Injected(\.fetchVcMetadataForAnyCredentialDispatcher) private var dispatcher: [CredentialFormat: FetchVcMetadataForAnyCredentialUseCaseProtocol]
  @Injected(\.jsonSchemaValidator) private var jsonSchemaValidator: JsonSchemaValidatorProtocol
  @Injected(\.ocaBundler) private var ocaBundler: OcaBundlerProtocol
}
