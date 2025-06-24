import BITJsonCanonicalizer
import BITJWT
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

  // MARK: - UseCases

  public var fetchClientAttestationUseCase: Factory<FetchClientAttestationUseCaseProtocol> {
    self { FetchClientAttestationUseCase() }
  }

  public var fetchKeyAttestationUseCase: Factory<FetchKeyAttestationUseCaseProtocol> {
    self { FetchKeyAttestationUseCase() }
  }

  public var generateClientAttestedRequestUseCase: Factory<GenerateClientAttestedRequestUseCaseProtocol> {
    self { GenerateClientAttestedRequestUseCase() }
  }

  public var appAttestationRepository: Factory<AppAttestationRepositoryProtocol> {
    self { AppAttestationRepository() }
  }

  // MARK: Internal

  var jsonCanonicalizer: Factory<JsonCanonicalizerProtocol> {
    self { JsonCanonicalizer() }
  }

  // MARK: - Services

  var appAttestationService: Factory<AppAttestationServiceProtocol> {
    self { AppAttestationService() }
  }

  var deviceCheckAppAttestService: Factory<DeviceCheckAppAttestServiceProtocol> {
    self { DCAppAttestService.shared }
  }

  var generateProofOfPossessionUseCase: Factory<GenerateProofOfPossessionUseCaseProtocol> {
    self { GenerateProofOfPossessionUseCase() }
  }

  // MARK: - Repositories

  var clientAttestationRepository: Factory<ClientAttestationRepositoryProtocol> {
    self { ClientAttestationRepository() }
  }

  // MARK: - Validators

  var clientAttestationValidator: Factory<ClientAttestationValidatorProtocol> {
    self { ClientAttestationValidator() }
  }

  var keyAttestationValidator: Factory<KeyAttestationValidatorProtocol> {
    self { KeyAttestationValidator() }
  }

}
