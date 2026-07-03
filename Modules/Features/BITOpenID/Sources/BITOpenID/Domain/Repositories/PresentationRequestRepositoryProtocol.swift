import Foundation
import Spyable

@Spyable
public protocol PresentationRequestRepositoryProtocol {
  func fetch(from url: URL) async throws -> RequestObjectJWS
  func submit(authorizationResponse: AuthorizationResponseBody, to url: URL) async throws
  func decline(url: URL, with error: PresentationErrorRequestBody.Code) async throws
}
