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

  private func makeContext(from parJwt: String) async throws -> PresentationRequestContext {
    let requestObject = try decodeRequestObject(from: parJwt)
    let compatibleCredentials = try await getCompatibleCredentialsUseCase.execute(using: requestObject)

    return PresentationRequestContext(
      presentationRequest: .plain(requestObject),
      compatibleCredentials: compatibleCredentials,
      transport: .proximity)
  }

  private func decodeRequestObject(from parJwt: String) throws -> RequestObject {
    let data = Data(parJwt.utf8)

    var jwsError: Error?
    do {
      let jws = try jwsDecoder.decode(RequestObjectJWT.self, from: data)
      return jws.payload
    } catch {
      jwsError = error
    }
    do {
      return try JSONDecoder().decode(RequestObject.self, from: data)
    } catch {
      throw RequestObjectError.invalidPayload(jwsError ?? error)
    }
  }

  private func mapToEvent(update: ProximityEngagementUpdate) async throws -> ProximityEngagementEvent {
    switch update {
    case .qrCode(let qrCode):
      .qrCode(qrCode)
    case .request(let parJwt):
      try .request(await makeContext(from: parJwt))
    }
  }

}
