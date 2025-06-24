import BITAppAuth
import BITCrypto
import BITJWT
import BITLocalAuthentication
import Factory
import Foundation
import Spyable

// MARK: - FetchClientAttestationUseCaseProtocol

@Spyable
public protocol FetchClientAttestationUseCaseProtocol {
  @discardableResult
  func execute(_ context: LAContextProtocol) async throws -> ClientAttestation
}

// MARK: - FetchClientAttestationUseCase

struct FetchClientAttestationUseCase: FetchClientAttestationUseCaseProtocol {

  // MARK: Internal

  func execute(_ context: LAContextProtocol) async throws -> ClientAttestation {
    let challenge = try await appAttestationRepository.fetchChallenge()
    let appAttestedKey = try await appAttestationService.generateAttestedKey(with: challenge)
    let bindingKey = try appAttestationKeyRepository.createAttestationKey(for: .clientAttestation, with: context)

    let clientData = try createClientData(challenge: challenge, bindingKey: bindingKey)
    let appAssertion = try await appAttestationService.generateAppAssertion(for: appAttestedKey.identifier, with: clientData)

    let clientAttestationRequestBody = ClientAttestationRequestBody(
      appAttestation: appAttestedKey.clientData.base64EncodedString(),
      appAssertion: appAssertion.base64EncodedString(),
      clientData: clientData)
    let clientAttestation = try await appAttestationRepository.fetchClientAttestation(clientAttestationRequestBody)

    return try await saveClientAttestation(clientAttestation)
  }

  // MARK: Private

  @Injected(\.appAttestationService) private var appAttestationService: AppAttestationServiceProtocol
  @Injected(\.appAttestationRepository) private var appAttestationRepository: AppAttestationRepositoryProtocol
  @Injected(\.appAttestationKeyRepository) private var appAttestationKeyRepository: AppAttestationKeyRepositoryProtocol
  @Injected(\.clientAttestationValidator) private var clientAttestationValidator: ClientAttestationValidatorProtocol
  @Injected(\.clientAttestationRepository) private var clientAttestationRepository: ClientAttestationRepositoryProtocol

  private func createClientData(challenge: AttestationChallenge, bindingKey: SecKey) throws -> ClientDataObject {
    let keyPair = KeyPair(privateKey: bindingKey)

    guard let publicKey = keyPair.publicKey, let jwk = try? JWK(from: publicKey) else {
      throw FetchClientAttestationUseCase.Error.invalidBindingKey
    }

    return ClientDataObject(challenge: challenge, bindingKey: BindingKey(jwk: jwk))
  }

  private func saveClientAttestation(_ clientAttestation: ClientAttestation) async throws -> ClientAttestation {
    guard await clientAttestationValidator.validate(clientAttestation) else {
      throw FetchClientAttestationUseCase.Error.invalidClientAttestation
    }

    return try await clientAttestationRepository.create(clientAttestation)
  }

}

// MARK: FetchClientAttestationUseCase.Error

extension FetchClientAttestationUseCase {
  enum Error: Swift.Error {
    case invalidBindingKey
    case invalidClientAttestation
  }
}
