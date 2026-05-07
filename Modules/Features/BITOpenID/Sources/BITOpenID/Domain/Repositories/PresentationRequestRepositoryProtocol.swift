import Foundation
import Spyable

@Spyable
public protocol PresentationRequestRepositoryProtocol {
  func fetch(from url: URL) async throws -> PresentationRequest
  func submit(authorizationResponse: AuthorizationResponseBody, to url: URL) async throws
  func decline(url: URL, with error: PresentationErrorRequestBody.Code) async throws
}
