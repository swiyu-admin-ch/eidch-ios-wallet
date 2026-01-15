import BITActivity
import BITOpenID
import Factory
import Foundation
import Spyable

// MARK: - DeclinePresentationUseCaseProtocol

@Spyable
public protocol DeclinePresentationUseCaseProtocol {
  func callAsFunction(context: PresentationRequestContext) async throws
  func callAsFunction(url: URL) async throws
}

// MARK: - DeclinePresentationUseCase

struct DeclinePresentationUseCase: DeclinePresentationUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(context: PresentationRequestContext) async throws {
    guard let credential = context.selectedCredential else {
      assertionFailure("No credential selected")
      return
    }
    let activity = Activity(context: context, credential: credential, type: .presentationDeclined)
    _ = try? activityService.create(activity, credentialId: credential.id)
    try await presentationRequestService.decline(url: context.requestObject.responseUri, with: .clientRejected)
  }

  func callAsFunction(url: URL) async throws {
    try await presentationRequestService.decline(url: url, with: .clientRejected)
  }

  // MARK: Private

  @Injected(\.presentationRequestService) private var presentationRequestService
  @Injected(\.activityService) private var activityService
}
