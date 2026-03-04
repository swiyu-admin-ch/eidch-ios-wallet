import BITOpenID
import BITPresentation
import Foundation

// MARK: - MockPresentationRequestRepository

struct MockPresentationRequestRepository: PresentationRequestRepositoryProtocol {

  func fetch(from url: URL) async throws -> PresentationRequest {
    .plain(RequestObject.Mock.sample)
  }

  func submit(authorizationResponse: AuthorizationResponseBody, to url: URL) async throws {
    // mock
  }

  func decline(url: URL, with error: PresentationErrorRequestBody.ErrorType) async throws {
    // mock
  }
}

// MARK: - RequestObject.Mock

extension RequestObject {
  enum Mock {
    static let sample: RequestObject = Mocker.decode(fromFile: "request-object-multipass")
  }
}
