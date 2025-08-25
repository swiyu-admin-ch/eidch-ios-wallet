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
        fatalError("No valid URL for SID url")
      }
      return url
    }
  }

  public var attestationServiceTrustedDids: Factory<[String]> {
    self { [] }
  }

  public var fetchClientAttestationUseCase: Factory<FetchClientAttestationUseCaseProtocol> {
    self { FetchClientAttestationUseCase() }
  }

  public var fetchKeyAttestationUseCase: Factory<FetchKeyAttestationUseCaseProtocol> {
    self { FetchKeyAttestationUseCase() }
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

  // MARK: Internal

  var keyAttestationValidator: Factory<KeyAttestationValidatorProtocol> {
    self { KeyAttestationValidator() }
  }

  var appAttestationRepository: Factory<AppAttestationRepositoryProtocol> {
    self { AppAttestationRepository() }
  }

  var jsonCanonicalizer: Factory<JsonCanonicalizerProtocol> {
    self { JsonCanonicalizer() }
  }

  var appAttestationService: Factory<AppAttestationServiceProtocol> {
    self { AppAttestationService() }
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
