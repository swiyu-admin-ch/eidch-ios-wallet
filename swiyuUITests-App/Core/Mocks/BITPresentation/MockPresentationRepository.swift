import BITOpenID
import BITPresentation
import Foundation

struct MockPresentationRepository: PresentationRepositoryProtocol {

  func submitPresentation(from url: URL, presentationRequestBody: PresentationRequestBody) async throws {
    // mock
  }

  func submitPresentation(from url: URL, presentationErrorRequestBody: PresentationErrorRequestBody) async throws {
    // mock
  }
}
