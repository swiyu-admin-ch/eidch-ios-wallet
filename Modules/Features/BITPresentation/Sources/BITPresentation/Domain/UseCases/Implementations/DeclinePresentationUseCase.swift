import BITActivity
import BITNetworking
import BITOpenID
import Factory
import Foundation
import Spyable

// MARK: - DeclinePresentationUseCaseProtocol

@Spyable
public protocol DeclinePresentationUseCaseProtocol {
  func callAsFunction(context: PresentationRequestContext) async throws -> PresentationResponse?
  func callAsFunction(url: URL) async throws -> PresentationResponse?
}

// MARK: - DeclinePresentationUseCase

struct DeclinePresentationUseCase: DeclinePresentationUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(context: PresentationRequestContext) async throws -> PresentationResponse? {
    switch context.transport {
    case .proximity:
      proximityRepository.decline()
      recordActivity(context: context)
      return nil
    case .network:
      guard let responseUri = context.requestObject.responseUri else {
        return nil
      }
      do {
        let presentationResponse = try await presentationRequestService.decline(url: responseUri, with: .accessDenied)
        recordActivity(context: context)
        return presentationResponse
      } catch {
        if shouldRecordPresentationActivity(after: error) {
          recordActivity(context: context)
        }

        throw error
      }
    }
  }

  func callAsFunction(url: URL) async throws -> PresentationResponse? {
    try await presentationRequestService.decline(url: url, with: .accessDenied)
  }

  // MARK: Private

  @Injected(\.presentationRequestService) private var presentationRequestService
  @Injected(\.activityService) private var activityService
  @Injected(\.proximityPresentationRepository) private var proximityRepository

  private func shouldRecordPresentationActivity(after error: Error) -> Bool {
    if error is PresentationResponseValidationError {
      return true
    }

    guard let networkError = error as? NetworkError else {
      return false
    }

    switch networkError.status {
    case .hostnameNotFound,
         .noConnection,
         .timeout,
         .unknown:
      return false
    default:
      return true
    }
  }

  private func recordActivity(context: PresentationRequestContext) {
    guard let credential = context.selectedCredential else { return }

    let activity = Activity(context: context, credential: credential, type: .presentationDeclined)
    _ = try? activityService.create(activity, credentialId: credential.id)
  }
}
