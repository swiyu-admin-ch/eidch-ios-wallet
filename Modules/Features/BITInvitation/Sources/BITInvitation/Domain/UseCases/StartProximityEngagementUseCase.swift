import BITCredential
import BITJWT
import BITOpenID
import BITPresentation
import Factory
import Foundation
import Spyable

// MARK: - StartProximityEngagementUseCaseProtocol

@Spyable
public protocol StartProximityEngagementUseCaseProtocol {
  func callAsFunction(qrCode: String?) -> AsyncThrowingStream<ProximityEngagementEvent, Error>
}

extension StartProximityEngagementUseCaseProtocol {
  func callAsFunction() -> AsyncThrowingStream<ProximityEngagementEvent, Error> {
    callAsFunction(qrCode: nil)
  }
}

// MARK: - ProximityEngagementEvent

public enum ProximityEngagementEvent: Equatable {
  case qrCode(String)
  case request(PresentationRequestContext)
}

// MARK: - StartProximityEngagementUseCase

final class StartProximityEngagementUseCase: StartProximityEngagementUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(qrCode: String?) -> AsyncThrowingStream<ProximityEngagementEvent, Error> {
    let stream = if let qrCode {
      repository.startEngagementReverse(qrCode: qrCode)
    } else {
      repository.startEngagement()
    }
    return AsyncThrowingStream { continuation in
      let task = Task {
        do {
          for try await update in stream {
            try await continuation.yield(mapToEvent(update: update))
          }
          continuation.finish()
        } catch {
          continuation.finish(throwing: error)
        }
      }
      continuation.onTermination = { _ in task.cancel() }
    }
  }

  // MARK: Private

  @Injected(\.proximityPresentationRepository) private var repository: ProximityPresentationRepositoryProtocol
  @Injected(\.getCompatibleCredentialsUseCase) private var getCompatibleCredentialsUseCase: GetCompatibleCredentialsUseCaseProtocol
  @Injected(\.jwsDecoder) private var jwsDecoder: JWSDecoderProtocol
  @Injected(\.requestObjectValidator) private var requestObjectValidator: RequestObjectValidatorProtocol

  private func makeContext(from parJwt: String, withOrigin: String?) async throws -> PresentationRequestContext {
    let requestObject = try await validatedRequestObject(from: parJwt)


    let compatibleCredentials = try await getCompatibleCredentialsUseCase(using: requestObject.payload)

    // At this point, we trust the check app
    let context = PresentationRequestContext(
      requestObjectJWS: requestObject,
      compatibleCredentials: compatibleCredentials,
      transport: .proximity,
      origin: withOrigin)
    context.trustInformation = TrustInformation(identity: .trustedCheckApp, vcSchema: .trusted)
    context.actorCompliance = .compliant
    return context
  }

  private func validatedRequestObject(from parJwt: String) async throws -> RequestObjectJWS {
    do {
      let requestObject = try decode(parJwt)
      do {
        try await requestObjectValidator.validate(requestObject, transport: .proximity)
      } catch {
        throw PresentationRequestError(validationError: error, responseURL: nil)
      }
      return requestObject
    } catch let error as PresentationRequestError {
      switch error {
      case .invalidRequestUrl:
        throw StartProximityEngagementUseCaseError.invalidRequest("invalid requestUrl")
      case .expired:
        throw StartProximityEngagementUseCaseError.expired
      case .invalid(_, let responseError):
        repository.decline()
        throw StartProximityEngagementUseCaseError.invalidRequest(responseError.rawValue)
      case .transactionDataNotSupported(_, let responseError):
        repository.decline()
        throw StartProximityEngagementUseCaseError.transactionDataNotSupported(
          responseError.rawValue)
      case .presentationRequestNotFound:
        throw StartProximityEngagementUseCaseError.notFound
      }
    } catch {
      throw StartProximityEngagementUseCaseError.invalidRequest(error.localizedDescription)
    }
  }

  private func decode(_ parJwt: String) throws -> RequestObjectJWS {
    do {
      return try jwsDecoder.decode(RequestObjectJWT.self, from: Data(parJwt.utf8))
    } catch {
      throw PresentationRequestError.invalid(responseURL: nil, responseError: .invalidRequest)
    }
  }

  private func mapToEvent(update: ProximityEngagementUpdate) async throws -> ProximityEngagementEvent {
    switch update {
    case .qrCode(let qrCode):
      .qrCode(qrCode)
    case .request(let requestObject, let origin):
      try .request(await makeContext(from: requestObject, withOrigin: origin))
    }
  }
}

// MARK: - StartProximityEngagementUseCaseError

enum StartProximityEngagementUseCaseError: Error, Equatable {
  case invalidOrigin
  case invalidRequest(String)
  case transactionDataNotSupported(String)
  case expired
  case notFound
}
