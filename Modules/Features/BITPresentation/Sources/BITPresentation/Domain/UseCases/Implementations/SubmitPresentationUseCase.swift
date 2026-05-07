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
            throw PresentationError.authorizationRequestError
          }

          // Record activity
          let activity = Activity(context: context, credential: selectedCredential, type: .presentationAccepted)
          _ = try? activityService.create(activity, credentialId: selectedCredential.id)

          let authorizationResponseBody: AuthorizationResponseBody

          do {
            authorizationResponseBody = try authorizationResponseBodyGenerator(
              for: selectedCredential,
              requestObject: context.requestObject,
              inputDescriptor: context.requestObject.firstInputDescriptor)
          } catch RequestObjectError.invalidPayload {
            throw PresentationError.authorizationRequestError
          }

          try await rotateNextPresentableBundleItemUseCase(selectedCredential.credential)

          try await submit(
            for: context,
            authorizationResponseBody: authorizationResponseBody,
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
  @Injected(\.activityService) private var activityService
  @Injected(\.rotateNextPresentableBundleItemUseCase) private var rotateNextPresentableBundleItemUseCase: RotateNextPresentableBundleItemUseCaseProtocol

  private func submit(
    for context: PresentationRequestContext,
    authorizationResponseBody: AuthorizationResponseBody,
    continuation: AsyncThrowingStream<SubmitPresentationEvent, Error>.Continuation) async throws
  {
    switch context.transport {
    case .proximity:
      try await submitOverProximity(authorizationResponseBody: authorizationResponseBody, continuation: continuation)
    case .network:
      try await submitOverNetwork(context: context, authorizationResponseBody: authorizationResponseBody)
      continuation.yield(.success)
      continuation.finish()
    }
  }

  private func submitOverProximity(
    authorizationResponseBody: AuthorizationResponseBody,
    continuation: AsyncThrowingStream<SubmitPresentationEvent, Error>.Continuation) async throws
  {
    for try await proximityEvent in proximityRepository.submit(presentationRequestBody: authorizationResponseBody) {
      switch proximityEvent {
      case .progress(let progress):
        continuation.yield(.progress(progress))
      case .success:
        continuation.yield(.success)
        continuation.finish()
        return
      }
    }
  }

  private func submitOverNetwork(
    context: PresentationRequestContext,
    authorizationResponseBody: AuthorizationResponseBody) async throws
  {
    guard let responseUri = context.requestObject.responseUri else {
      throw PresentationError.authorizationRequestError
    }

    do {
      try await repository.submit(authorizationResponse: authorizationResponseBody, to: responseUri)
    } catch {
      throw PresentationError(error) ?? error
    }
  }
}
