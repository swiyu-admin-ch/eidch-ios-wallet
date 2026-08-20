import BITJWT
import BITOpenID
import BITSwiyuSharedKMP
import Factory
import Foundation

// MARK: - ProximityPresentationRepository

final class ProximityPresentationRepository: ProximityPresentationRepositoryProtocol {

  // MARK: Lifecycle

  init() {}

  // MARK: Internal

  // MARK: ProximityPresentationRepositoryProtocol

  func startEngagement() -> AsyncThrowingStream<ProximityEngagementUpdate, Error> {
    start { [weak self] in
      self?.controller.startEngagement()
    }
  }

  func startEngagementReverse(qrCode: String) -> AsyncThrowingStream<ProximityEngagementUpdate, Error> {
    start { [weak self] in
      self?.controller.startEngagementReverse(readerEngagement: qrCode)
    }
  }

  func submit(authorizationResponse: AuthorizationResponse) -> AsyncThrowingStream<ProximitySubmissionEvent, Error> {
    AsyncThrowingStream(ProximitySubmissionEvent.self) { continuation in
      let task = Task {
        do {
          let data = try JSONSerialization.data(withJSONObject: authorizationResponse.asDictionary())

          let stream = controller.stateValues()

          controller.submitDocument(data: data.toByteArray())

          for try await state in stream {
            switch BITSwiyuSharedKMP.onEnum(of: state) {
            case .submittingDocuments(let params):
              continuation.yield(.progress(params.progress?.doubleValue))
            case .presentationCompleted:
              continuation.yield(.success)
              continuation.finish()
              return
            case .error(let params):
              continuation.finish(throwing: ProximitySubmissionError.failed(underlyingErrorMessage: params.error.message))
              return
            case .disconnected:
              continuation.finish(throwing: ProximitySubmissionError.disconnected)
              return
            default:
              continue
            }
          }

          continuation.finish(throwing: ProximitySubmissionError.unexpectedTermination)
        } catch {
          continuation.finish(throwing: error)
        }
      }
      continuation.onTermination = { @Sendable _ in
        task.cancel()
      }
    }
  }

  func decline() {
    controller.decline()
  }

  // MARK: Private

  @Injected(\.proximityPresentationController) private var controller: ProximityPresentationControllerProtocol

  private func start(_ starter: @Sendable @escaping () -> Void) -> AsyncThrowingStream<ProximityEngagementUpdate, Error> {
    AsyncThrowingStream { continuation in
      let task = Task {
        starter()
        await streamEngagementStates(into: continuation)
      }

      continuation.onTermination = { _ in task.cancel() }
    }
  }
}

// MARK: - Engagement Streaming

extension ProximityPresentationRepository {
  fileprivate func streamEngagementStates(into continuation: AsyncThrowingStream<ProximityEngagementUpdate, Error>.Continuation) async {
    do {
      let stream = controller.stateValues()
      for try await state in stream {
        switch BITSwiyuSharedKMP.onEnum(of: state) {
        case .readyForEngagement(let params):
          continuation.yield(.qrCode(params.qrCodeData))
        case .requestingDocuments(let params):
          continuation.yield(.request(requestObject: params.raw, origin: params.origin))
          continuation.finish()
          return
        case .error(let params):
          continuation.finish(throwing: ProximitySubmissionError.failed(underlyingErrorMessage: params.error.message))
          return
        case .disconnected:
          continuation.finish(throwing: ProximitySubmissionError.disconnected)
          return
        default:
          continue
        }
      }
      continuation.finish(throwing: ProximitySubmissionError.unexpectedTermination)
    } catch {
      continuation.finish(throwing: error)
    }
  }
}
