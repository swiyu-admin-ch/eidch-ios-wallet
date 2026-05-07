import BITSwiyuSharedKMP
import Foundation
import Spyable

// MARK: - ProximityPresentationControllerProtocol

@Spyable
protocol ProximityPresentationControllerProtocol {
  func startEngagement()
  func startEngagementReverse(readerEngagement: String)
  func submitDocument(data: KotlinByteArray)
  func decline()
  func stateValues() -> AsyncThrowingStream<ProximityState, Error>
}

// MARK: - ProximityPresentationController + ProximityPresentationControllerProtocol

extension ProximityPresentationController: ProximityPresentationControllerProtocol {
  func stateValues() -> AsyncThrowingStream<ProximityState, Error> {
    AsyncThrowingStream { continuation in
      let task = Task {
        do {
          for try await state in self.state.toPublisher().values {
            continuation.yield(state)
          }
          continuation.finish()
        } catch {
          continuation.finish(throwing: error)
        }
      }
      continuation.onTermination = { _ in task.cancel() }
    }
  }
}
