import BITCrypto
import BITJWT
import BITNetworking
import Factory
import Foundation
import Moya

// MARK: - PresentationRequestRepository

struct PresentationRequestRepository: PresentationRequestRepositoryProtocol {

  // MARK: Internal

  func fetch(from url: URL) async throws -> RequestObjectJWS {
    do {
      let data = try await networkService.request(PresentationEndpoint.requestObject(url: url)).data
      return try jwsDecoder.decode(RequestObjectJWT.self, from: data)
    } catch let error as NetworkError where error.status == .gone {
      throw PresentationRequestRepositoryError.presentationRequestExpired
    } catch let error as NetworkError where error.status == .notFound {
      throw PresentationRequestRepositoryError.presentationRequestNotFound
    }
  }

  func submit(authorizationResponse: AuthorizationResponse, to url: URL, encryption: AuthorizationResponseEncryption) async throws -> PresentationResponse? {
    let data = try JSONSerialization.data(withJSONObject: authorizationResponse.asDictionary())
    let jwe = try jweEncrypter.encrypt(
      data: data,
      publicKey: encryption.jwk,
      encryptionAlgorithm: encryption.algorithm,
      compressionAlgorithm: nil)

    let response = try await networkService.request(PresentationEndpoint.submission(url: url, jwe: jwe))
    return try decodePresentationResponse(response)
  }

  func decline(url: URL, with error: PresentationErrorRequestBody.Code) async throws -> PresentationResponse? {
    let presentationErrorRequestBody = PresentationErrorRequestBody(error: error)
    let response = try await networkService.request(PresentationEndpoint.errorSubmission(url: url, presentationErrorBody: presentationErrorRequestBody))
    return try decodePresentationResponse(response)
  }

  // MARK: Private

  @Injected(\NetworkContainer.service) private var networkService
  @Injected(\NetworkContainer.decoder) private var decoder
  @Injected(\.jwsDecoder) private var jwsDecoder
  @Injected(\.jweEncrypter) private var jweEncrypter

  private func decodePresentationResponse(_ response: Response) throws -> PresentationResponse? {
    guard response.statusCode == 200, !response.data.isEmpty else {
      return nil
    }

    do {
      return try decoder.decode(PresentationResponse.self, from: response.data)
    } catch let error as PresentationResponseValidationError {
      throw error
    } catch {
      return nil
    }
  }
}

// MARK: - PresentationRequestRepositoryError

public enum PresentationRequestRepositoryError: Error, Equatable {
  case presentationRequestExpired
  case presentationRequestNotFound
}
