import BITAppAuth
import BITCrypto
import BITJWT
import BITLocalAuthentication
import Factory
import Spyable

// MARK: - FetchKeyAttestationUseCaseProtocol

@Spyable
public protocol FetchKeyAttestationUseCaseProtocol {
  func execute(_ context: LAContextProtocol) async throws -> KeyAttestation
}

// MARK: - FetchKeyAttestationUseCase

struct FetchKeyAttestationUseCase: FetchKeyAttestationUseCaseProtocol {

  // MARK: Internal

  func execute(_ context: LAContextProtocol) async throws -> KeyAttestation {
    let challenge = try await appAttestationRepository.fetchChallenge()
    let requestBody = try createRequestBody(context: context)
    let clientAttestation = try await clientAttestationRepository.getClientAttestation()

    let request = try await generateClientAttestedRequestUseCase.execute(for: requestBody, challenge: challenge, audience: clientAttestation.payload.issuer)
    let keyAttestation = try await appAttestationRepository.fetchKeyAttestation(with: request)

    guard await keyAttestationValidator.validate(keyAttestation) else {
      throw FetchKeyAttestationUseCase.Error.invalidKeyAttestation
    }

    return keyAttestation
  }

  // MARK: Private

  @Injected(\.keyAttestationValidator) private var keyAttestationValidator: KeyAttestationValidatorProtocol
  @Injected(\.appAttestationRepository) private var appAttestationRepository: AppAttestationRepositoryProtocol
  @Injected(\.appAttestationKeyRepository) private var appAttestationKeyRepository: AppAttestationKeyRepositoryProtocol
  @Injected(\.clientAttestationRepository) private var clientAttestationRepository: ClientAttestationRepositoryProtocol
  @Injected(\.generateClientAttestedRequestUseCase) private var generateClientAttestedRequestUseCase: GenerateClientAttestedRequestUseCaseProtocol

  private func createRequestBody(context: LAContextProtocol) throws -> KeyAttestationRequestBody {
    let privateKey = try appAttestationKeyRepository.createAttestationKey(for: .keyAttestation, with: context)
    let keyPair = KeyPair(privateKey: privateKey)

    guard
      let publicKey = keyPair.publicKey,
      let jwk = try? JWK(from: publicKey)
    else {
      throw FetchKeyAttestationUseCase.Error.invalidBindingKey
    }

    return KeyAttestationRequestBody(bindingKey: BindingKey(jwk: jwk))
  }
}

// MARK: FetchKeyAttestationUseCase.Error

extension FetchKeyAttestationUseCase {
  enum Error: Swift.Error {
    case invalidKeyAttestation
    case invalidBindingKey
  }
}
