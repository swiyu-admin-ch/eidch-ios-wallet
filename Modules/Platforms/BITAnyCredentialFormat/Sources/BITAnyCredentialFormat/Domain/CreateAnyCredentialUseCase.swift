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
      return try sdJwsDecoder.decode(VcSdJwtPayload.self, from: data)
    default:
      throw CreateAnyCredentialUseCaseError.credentialFormatNotSupported
    }
  }

  // MARK: Private

  @Injected(\.sdJwsDecoder) private var sdJwsDecoder: SdJWSDecoderProtocol

}

// MARK: CreateAnyCredentialUseCase.CreateAnyCredentialUseCaseError

extension CreateAnyCredentialUseCase {
  enum CreateAnyCredentialUseCaseError: Error {
    case credentialPayloadInvalid
    case credentialFormatNotSupported
  }
}
