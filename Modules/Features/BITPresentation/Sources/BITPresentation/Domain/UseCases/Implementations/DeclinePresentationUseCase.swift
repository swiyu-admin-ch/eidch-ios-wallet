import BITActivity
import BITOpenID
import Factory
import Foundation
import Spyable

// MARK: - DeclinePresentationUseCaseProtocol

@Spyable
public protocol DeclinePresentationUseCaseProtocol {
  func execute(context: PresentationRequestContext) async throws
}

// MARK: - DeclinePresentationUseCase

struct DeclinePresentationUseCase: DeclinePresentationUseCaseProtocol {

  func execute(context: PresentationRequestContext) async throws {
    guard let credential = context.selectedCredential else {
      assertionFailure("No credential selected")
      return
    }
    let activity = Activity(context: context, credential: credential, type: .presentationDeclined)
    _ = try? activityService.create(activity, credentialId: credential.id)
    try await presentationRequestService.decline(for: context.requestObject, with: .clientRejected)
  }

  @Injected(\.presentationRequestService) private var presentationRequestService
  @Injected(\.activityService) private var activityService
}
