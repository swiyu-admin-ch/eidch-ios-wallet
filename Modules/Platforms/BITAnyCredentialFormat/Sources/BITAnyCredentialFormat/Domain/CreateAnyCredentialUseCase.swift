import BITSdJWT
import Factory
import Foundation
import Spyable

// MARK: - CreateAnyCredentialUseCaseProtocol

@Spyable
public protocol CreateAnyCredentialUseCaseProtocol {
  func execute(from payload: CredentialPayload, format: String) throws -> AnyCredential
}

// MARK: - CreateAnyCredentialUseCase

struct CreateAnyCredentialUseCase: CreateAnyCredentialUseCaseProtocol {

  // MARK: Internal

  func execute(from payload: CredentialPayload, format: String) throws -> AnyCredential {
    guard let rawCredential = String(data: payload, encoding: .utf8) else {
      throw CreateAnyCredentialUseCaseError.credentialPayloadInvalid
    }

    guard let credentialFormat = CredentialFormat(rawValue: format) else {
      throw CreateAnyCredentialUseCaseError.credentialFormatNotSupported
    }

    switch credentialFormat {
    case .vcSdJwt:
      let data = rawCredential.data(using: .utf8) ?? Data()
      return try vcSdJwsDecoder.decode(VcSdJwt.self, from: data)
    }
  }

  // MARK: Private

  @Injected(\.vcSdJwsDecoder) private var vcSdJwsDecoder: VcSdJWSDecoderProtocol

}

// MARK: CreateAnyCredentialUseCase.CreateAnyCredentialUseCaseError

extension CreateAnyCredentialUseCase {
  enum CreateAnyCredentialUseCaseError: Error {
    case credentialPayloadInvalid
    case credentialFormatNotSupported
  }
}
