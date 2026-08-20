import BITActivity
import BITAnyCredentialFormat
import BITCredential
import BITCredentialShared
import BITCrypto
import BITLocalAuthentication
import BITNetworking
import BITOpenID
import BITVault
import Factory
import Foundation

// MARK: - SubmitPresentationUseCaseError

enum SubmitPresentationUseCaseError: Error {
  case missingSelectedCredential
  case missingResponseUri
  case invalidAuthorizationRequest
}

// MARK: - SubmitPresentationUseCase

public struct SubmitPresentationUseCase: SubmitPresentationUseCaseProtocol {

  // MARK: Public

  /// `important`: The implementation supports and takes only the first input descriptor give by the context
  ///
  /// The supports of multiple input descriptor has to be defined.
  public func execute(context: PresentationRequestContext) -> AsyncThrowingStream<SubmitPresentationEvent, Error> {
    AsyncThrowingStream(SubmitPresentationEvent.self) { continuation in
      let task = Task {
        do {
          #warning("The submit should take in consideration multiple input descriptors in the future. For now it only takes the first one given by the context.")

          guard let selectedCredential = context.selectedCredential else {
            throw SubmitPresentationUseCaseError.missingSelectedCredential
          }

          let authorizationResponse: AuthorizationResponse

          do {
            authorizationResponse = try authorizationResponseBodyGenerator(for: selectedCredential, requestObject: context.requestObject, withOrigin: context.origin)
          } catch RequestObjectError.invalidPayload, RequestObjectError.invalidQuery {
            throw SubmitPresentationUseCaseError.invalidAuthorizationRequest
          }

          try await rotateNextPresentableBundleItemUseCase(selectedCredential.credential)

          try await submit(
            for: context,
            authorizationResponse: authorizationResponse,
            continuation: continuation)
        } catch {
          continuation.finish(throwing: error)
        }
      }

      continuation.onTermination = { _ in task.cancel() }
    }
  }

  // MARK: Private

  @Injected(\.proximityPresentationRepository) private var proximityRepository: ProximityPresentationRepositoryProtocol
  @Injected(\.presentationRequestRepository) private var repository
  @Injected(\.authorizationResponseBodyGenerator) private var authorizationResponseBodyGenerator
  @Injected(\.authorizationResponseEncryptionGenerator) private var authorizationResponseEncryptionGenerator
  @Injected(\.activityService) private var activityService
  @Injected(\.rotateNextPresentableBundleItemUseCase) private var rotateNextPresentableBundleItemUseCase: RotateNextPresentableBundleItemUseCaseProtocol

  private func submit(
    for context: PresentationRequestContext,
    authorizationResponse: AuthorizationResponse,
    continuation: AsyncThrowingStream<SubmitPresentationEvent, Error>.Continuation) async throws
  {
    switch context.transport {
    case .proximity:
      try await submitOverProximity(
        authorizationResponse: authorizationResponse,
        context: context,
        continuation: continuation)
    case .network:
      let presentationResponse = try await submitOverNetwork(
        context: context,
        authorizationResponse: authorizationResponse)
      continuation.yield(.success(presentationResponse))
      continuation.finish()
    }
  }

  private func submitOverProximity(
    authorizationResponse: AuthorizationResponse,
    context: PresentationRequestContext,
    continuation: AsyncThrowingStream<SubmitPresentationEvent, Error>.Continuation) async throws
  {
    for try await proximityEvent in proximityRepository.submit(authorizationResponse: authorizationResponse) {
      switch proximityEvent {
      case .progress(let progress):
        continuation.yield(.progress(progress))
      case .success:
        recordActivity(context: context)
        continuation.yield(.success(nil))
        continuation.finish()
        return
      }
    }
  }

  private func submitOverNetwork(
    context: PresentationRequestContext,
    authorizationResponse: AuthorizationResponse) async throws
    -> PresentationResponse?
  {
    guard let responseUri = context.requestObject.responseUri else {
      throw SubmitPresentationUseCaseError.missingResponseUri
    }

    do {
      let encryption = try authorizationResponseEncryptionGenerator(for: context.requestObject.clientMetadata)
      let presentationResponse = try await repository.submit(authorizationResponse: authorizationResponse, to: responseUri, encryption: encryption)
      recordActivity(context: context)
      return presentationResponse
    } catch {
      if shouldRecordPresentationActivity(after: error) {
        recordActivity(context: context)
      }

      throw error
    }
  }

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
    guard let selectedCredential = context.selectedCredential else { return }

    let activity = Activity(context: context, credential: selectedCredential, type: .presentationAccepted)
    _ = try? activityService.create(activity, credentialId: selectedCredential.id)
  }
}
