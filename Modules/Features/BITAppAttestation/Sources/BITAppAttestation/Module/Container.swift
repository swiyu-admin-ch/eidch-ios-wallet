import BITJsonCanonicalizer
import BITJWT
import BITVault
import DeviceCheck
import Factory
import Foundation

extension Container {

  // MARK: Public

  public var attestationServiceUrl: Factory<URL> {
    self {
      guard let url = URL(string: "https://attestations.trust-infra.swiyu.admin.ch") else {
        fatalError("No valid URL for Attestation url")
      }
      return url
    }
  }

  public var attestationServiceTrustedDids: Factory<[String]> {
    self {
      [
        "did:tdw:QmVxp7q4pFKRp8zf7KftJBRroNRF6dVzHns3Sq7EdjxQep:identifier-reg.trust-infra.swiyu.admin.ch:api:v1:did:9f94645c-2b23-4f7d-9c8c-21c77e9995a5",
        "did:webvh:QmSnE8nCxzoFuXcJS9GoowDjX8rG3vsWy4fYbpvYEZpKEa:identifier-reg.trust-infra.swiyu.admin.ch:api:v1:did:0e547c8b-64bd-467e-a21f-8b959a1d38b4",
      ]
    }
  }

  public var clientAttestationRepository: Factory<ClientAttestationRepositoryProtocol> {
    self { ClientAttestationRepository() }
  }

  public var proofOfPossessionGenerator: Factory<ProofOfPossessionGeneratorProtocol> {
    self { ProofOfPossessionGenerator() }
  }

  public var appAttestationKeyRepository: Factory<AppAttestationKeyRepositoryProtocol> {
    self { AppAttestationKeyRepository() }
  }

  public var keyAttestationValidator: Factory<KeyAttestationValidatorProtocol> {
    self { KeyAttestationValidator() }
  }

  public var attestationServiceRepository: Factory<AttestationServiceRepositoryProtocol> {
    self { AttestationServiceRepository() }
  }

  // MARK: Internal

  var appAttestationProvider: Factory<AppAttestationProviderProtocol> {
    self { AppAttestationProvider() }
  }

  var deviceCheckAppAttestService: Factory<DeviceCheckAppAttestServiceProtocol> {
    self { DCAppAttestService.shared }
  }

  var clientAttestationValidator: Factory<ClientAttestationValidatorProtocol> {
    self { ClientAttestationValidator() }
  }

  var attestationKeyAlgorithm: Factory<VaultAlgorithm> {
    self { .eciesEncryptionStandardVariableIVX963SHA256AESGCM }
  }

  var attestationKeyVaultOptions: Factory<VaultOptions> {
    self { .secureEnclavePermanently }
  }

}
