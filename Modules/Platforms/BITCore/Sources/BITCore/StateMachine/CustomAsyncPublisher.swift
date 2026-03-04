import Combine
import UIKit

// MARK: - CustomAsyncPublisher

struct CustomAsyncPublisher<P: Publisher>: AsyncSequence where P.Failure == Never {

  // MARK: Lifecycle

  init(_ upstream: AnyPublisher<P.Output, Never>) {
    self.upstream = upstream
  }

  // MARK: Internal

  typealias Element = P.Output
  typealias AsyncIterator = AsyncStream<P.Output>.AsyncIterator

  var upstream: AnyPublisher<P.Output, Never>

  func makeAsyncIterator() -> AsyncStream<Element>.AsyncIterator {
    var subscription: Subscription?

    let stream = AsyncStream<Element> { continuation in
      let mySubscriber = AnySubscriber<Element, Never>(
        receiveSubscription: { s in subscription = s; s.request(.max(1)) },
        receiveValue: { continuation.yield($0); return .max(1) },
        receiveCompletion: { _ in continuation.finish(); subscription?.cancel() })

      upstream.receive(subscriber: mySubscriber)
    }

    return stream.makeAsyncIterator()
  }
}

extension AnyPublisher where Failure == Never {

  @available(iOS 13, *)
  var values: CustomAsyncPublisher<Self> {
    CustomAsyncPublisher<Self>(self)
  }

}
