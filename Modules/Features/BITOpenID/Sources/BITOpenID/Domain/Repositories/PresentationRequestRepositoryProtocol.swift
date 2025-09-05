import Foundation
import Spyable

@Spyable
public protocol PresentationRequestRepositoryProtocol {
  func fetch(from url: URL) async throws -> PresentationRequest
  func submit(from url: URL, presentationRequestBody: PresentationRequestBody) async throws
  func decline(url: URL, with error: PresentationErrorRequestBody.ErrorType) async throws
}
