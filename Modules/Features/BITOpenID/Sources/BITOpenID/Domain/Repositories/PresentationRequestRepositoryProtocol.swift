import Foundation
import Spyable

@Spyable
public protocol PresentationRequestRepositoryProtocol {
  func fetch(from url: URL) async throws -> RequestObjectJWS
  func submit(authorizationResponse: AuthorizationResponse, to url: URL, encryption: AuthorizationResponseEncryption) async throws -> PresentationResponse?
  func decline(url: URL, with error: PresentationErrorRequestBody.Code) async throws -> PresentationResponse?
}
