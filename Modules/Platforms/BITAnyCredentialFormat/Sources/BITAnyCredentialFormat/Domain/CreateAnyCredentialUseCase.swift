import BITCore
import BITSdJWT
import Factory
import Foundation
import Spyable

// MARK: - CreateAnyCredentialUseCaseProtocol

@Spyable
public protocol CreateAnyCredentialUseCaseProtocol: Sendable {
  func execute(from payload: CredentialPayload, format: CredentialFormat) async throws -> AnyCredential
}

// MARK: - CreateAnyCredentialUseCase

struct CreateAnyCredentialUseCase: CreateAnyCredentialUseCaseProtocol {

  // MARK: Internal

  func execute(from payload: CredentialPayload, format: CredentialFormat) async throws -> AnyCredential {
    try await cacheManager.get(for: payload.sha256()) {
      switch format {
      case .dcSdJwt,
           .vcSdJwt:
        try vcSdJwsDecoder.decode(VcSdJwt.self, from: payload)
      }
    }
  }

  // MARK: Private

  @Injected(\.vcSdJwsDecoder) private var vcSdJwsDecoder: VcSdJWSDecoderProtocol
  private var cacheManager = CacheManager<AnyCredential>()

}

// MARK: CreateAnyCredentialUseCase.CreateAnyCredentialUseCaseError

extension CreateAnyCredentialUseCase {
  enum CreateAnyCredentialUseCaseError: Error {
    case credentialPayloadInvalid
  }
}
