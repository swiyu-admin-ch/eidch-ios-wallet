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
    if let credential = context.selectedCredential {
      let activity = Activity(context: context, credential: credential, type: .presentationDeclined)
      _ = try? activityService.create(activity, credentialId: credential.id)
    }

    switch context.transport {
    case .proximity:
      proximityRepository.decline()
    case .network:
      guard let responseUri = context.requestObject.responseUri else {
        return
      }
      try await presentationRequestService.decline(url: responseUri, with: .accessDenied)
    }
  }

  func callAsFunction(url: URL) async throws {
    try await presentationRequestService.decline(url: url, with: .accessDenied)
  }

  // MARK: Private

  @Injected(\.presentationRequestService) private var presentationRequestService
  @Injected(\.activityService) private var activityService
  @Injected(\.proximityPresentationRepository) private var proximityRepository
}
