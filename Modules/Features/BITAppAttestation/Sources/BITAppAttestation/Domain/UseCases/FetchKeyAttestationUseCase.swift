import BITCrypto
import BITJWT
import BITLocalAuthentication
import BITVault
import Factory
import Spyable

// MARK: - FetchKeyAttestationUseCaseProtocol

@Spyable
public protocol FetchKeyAttestationUseCaseProtocol {
  func execute(for keyPair: VaultKeyPair, _ context: LAContextProtocol) async throws -> KeyAttestation
}

// MARK: - FetchKeyAttestationUseCase

struct FetchKeyAttestationUseCase: FetchKeyAttestationUseCaseProtocol {

  // MARK: Internal

  func execute(for keyPair: VaultKeyPair, _ context: LAContextProtocol) async throws -> KeyAttestation {
    let clientAttestation = try await fetchClientAttestationUseCase.execute(context)
    let requestBody = try createRequestBody(keyPair: keyPair)
    let keyAttestation = try await appAttestationRepository.fetchKeyAttestation(body: requestBody, clientAttestation: clientAttestation)

    guard await keyAttestationValidator.validate(keyPair: keyPair, with: keyAttestation) else {
      throw FetchKeyAttestationUseCase.Error.invalidKeyAttestation
    }

    return keyAttestation
  }

  // MARK: Private

  @Injected(\.keyAttestationValidator) private var keyAttestationValidator: KeyAttestationValidatorProtocol
  @Injected(\.appAttestationRepository) private var appAttestationRepository: AppAttestationRepositoryProtocol
  @Injected(\.fetchClientAttestationUseCase) private var fetchClientAttestationUseCase: FetchClientAttestationUseCaseProtocol

  private func createRequestBody(keyPair: VaultKeyPair) throws -> KeyAttestationRequestBody {
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
