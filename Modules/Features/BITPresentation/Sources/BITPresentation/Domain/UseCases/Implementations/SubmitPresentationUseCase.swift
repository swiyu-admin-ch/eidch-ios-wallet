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

// MARK: - SubmitPresentationError

enum SubmitPresentationError: Error { #warning("TODO: merge with BITOpenID.SubmitPresentationError as soon as this use case has been moved to BITOpenID module")
  case presentationFailed
  case processClosed
  case invalidCredential
  case inputDescriptorsNotFound
}

// MARK: - SubmitPresentationUseCase

public struct SubmitPresentationUseCase: SubmitPresentationUseCaseProtocol {

  // MARK: Public

  /// `important`: The implementation supports and takes only the first input descriptor give by the context
  ///
  /// The supports of multiple input descriptor has to be defined.
  public func execute(context: PresentationRequestContext) async throws {
    #warning("The submit should take in consideration multiple input descriptors in the future. For now it only takes the first one given by the context.")

    guard let selectedCredential = context.selectedCredential else {
      throw SubmitPresentationError.inputDescriptorsNotFound
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
      throw SubmitPresentationError.inputDescriptorsNotFound
    }

    do {
      try await repository.submit(authorizationResponse: authorizationResponseBody, to: context.requestObject.responseUri)
    } catch BITOpenID.SubmitPresentationError.presentationFailed {
      throw SubmitPresentationError.presentationFailed
    } catch BITOpenID.SubmitPresentationError.processClosed {
      throw SubmitPresentationError.processClosed
    } catch BITOpenID.SubmitPresentationError.invalidCredential {
      throw SubmitPresentationError.invalidCredential
    }
  }

  // MARK: Private

  @Injected(\.presentationRequestRepository) private var repository
  @Injected(\.authorizationResponseBodyGenerator) private var authorizationResponseBodyGenerator
  @Injected(\.activityService) private var activityService

}
