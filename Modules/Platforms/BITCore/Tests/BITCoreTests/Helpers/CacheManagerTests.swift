import Factory
import Foundation
import Testing
@testable import BITCore
@testable import BITTestingCore

struct CacheManagerTests {

  // MARK: Lifecycle

  init() {
    Container.shared.currentDate.register { Self.referenceDate }

    cacheManager = CacheManager<String>(defaultTimeToLive: 5 * 60)
  }

  // MARK: Internal

  @Test
  func get_whenNoEntryExists_returnsValue() async throws {
    let cachedValue = try await cacheManager.get(for: key) {
      await fetchSpy.fetch(result: value)
    }

    #expect(cachedValue == value)
    #expect(await fetchSpy.callCount == 1)
  }

  @Test
  func get_whenEntryExistsAndIsNotExpired_returnsCachedValue() async throws {
    _ = try await cacheManager.get(for: key) {
      await fetchSpy.fetch(result: value)
    }

    let cachedValue = try await cacheManager.get(for: key) {
      await fetchSpy.fetch(result: otherValue)
    }

    #expect(cachedValue == value)
    #expect(await fetchSpy.callCount == 1)
  }

  @Test
  func get_whenEntryExpired_returnsNewValue() async throws {
    _ = try await cacheManager.get(for: key, timeToLive: 1) {
      await fetchSpy.fetch(result: value)
    }
    Container.shared.currentDate.register { Self.referenceDate.addingTimeInterval(2) }

    let cachedValue = try await cacheManager.get(for: key) {
      await fetchSpy.fetch(result: otherValue)
    }

    #expect(cachedValue == otherValue)
    #expect(await fetchSpy.callCount == 2)
  }

  @Test
  func get_whenDifferentKeys_returnsDifferentValues() async throws {
    let value1 = try await cacheManager.get(for: key) {
      await fetchSpy.fetch(result: value)
    }

    let value2 = try await cacheManager.get(for: otherKey) {
      await fetchSpy.fetch(result: otherValue)
    }

    #expect(value1 == value)
    #expect(value2 == otherValue)
    #expect(await fetchSpy.callCount == 2)
  }

  @Test
  func get_whenOneKeyExpires_doesNotAffectOtherKeys() async throws {
    _ = try await cacheManager.get(for: key, timeToLive: 1) {
      await fetchSpy.fetch(result: value)
    }
    _ = try await cacheManager.get(for: otherKey, timeToLive: 3) {
      await fetchSpy.fetch(result: otherValue)
    }
    Container.shared.currentDate.register { Self.referenceDate.addingTimeInterval(2) }

    let refreshedValue = try await cacheManager.get(for: key) {
      await fetchSpy.fetch(result: "value1")
    }
    let unaffectedValue = try await cacheManager.get(for: otherKey) {
      Issue.record("Fetch should never execute")
      return value
    }

    #expect(refreshedValue == "value1")
    #expect(unaffectedValue == otherValue)
    #expect(await fetchSpy.callCount == 3)
  }

  @Test
  func get_whenFetchFails_doesNotCacheFailure() async {
    await #expect(throws: TestingError.self) {
      try await cacheManager.get(for: key) {
        throw TestingError.error
      }
    }

    #expect(await fetchSpy.callCount == 0)
  }

  @Test
  func get_whenFetchAlreadyInProgress_returnsInFlightValue() async throws {
    async let value1: String = cacheManager.get(for: key) {
      await checkpoint.pause()
      return await fetchSpy.fetch(result: value)
    }
    await checkpoint.waitUntilPausedTasks(count: 1)

    async let value2 = try await cacheManager.get(for: key) {
      Issue.record("Second fetch should never execute")
      return otherValue
    }
    while await cacheManager.inFlightWaiterCount < 1 {
      await Task.yield()
    }
    await checkpoint.resumeNext()

    #expect(try await value1 == value)
    #expect(try await value2 == value)
    #expect(await fetchSpy.callCount == 1)
  }

  @Test
  func get_whenConcurrentFetchFails_returnsSameErrorAndOnlyFetchesOnce() async {
    async let request1: Void = {
      await #expect(throws: TestingError.self) {
        try await cacheManager.get(for: key) {
          await checkpoint.pause()
          throw TestingError.error
        }
      }
    }()
    await checkpoint.waitUntilPausedTasks(count: 1)

    async let request2: Void = {
      await #expect(throws: TestingError.self) {
        try await cacheManager.get(for: key) {
          Issue.record("Second fetch should never execute")
          throw TestingError.error
        }
      }
    }()
    while await cacheManager.inFlightWaiterCount < 1 {
      await Task.yield()
    }

    await checkpoint.resumeNext()

    _ = await (request1, request2)
  }

  @Test
  func get_whenFetchFails_thenSubsequentCallRefetches() async {
    await #expect(throws: TestingError.self) {
      try await cacheManager.get(for: key) {
        throw TestingError.error
      }
    }

    let result = try? await cacheManager.get(for: key) {
      await fetchSpy.fetch(result: value)
    }

    #expect(result == value)
    #expect(await fetchSpy.callCount == 1)
  }

  @Test
  func invalidateAll_whenCacheContainsEntries_clearsCachedValues() async throws {
    _ = try await cacheManager.get(for: key) {
      await fetchSpy.fetch(result: value)
    }

    await cacheManager.invalidateAll()

    let refreshedValue = try await cacheManager.get(for: key) {
      await fetchSpy.fetch(result: otherValue)
    }
    #expect(refreshedValue == otherValue)
    #expect(await fetchSpy.callCount == 2)
  }

  @Test
  func invalidateAll_whenFetchInProgress_cancelsTaskAndDoesNotCacheValue() async {
    async let request: Void = {
      await #expect(throws: CancellationError.self) {
        try await cacheManager.get(for: key) {
          await checkpoint.pause()
          try Task.checkCancellation()
          return value
        }
      }
    }()
    await checkpoint.waitUntilPausedTasks(count: 1)

    await cacheManager.invalidateAll()

    await checkpoint.resumeNext()
    _ = await request
    let refreshedValue = try? await cacheManager.get(for: key) {
      await fetchSpy.fetch(result: otherValue)
    }
    #expect(refreshedValue == otherValue)
    #expect(await fetchSpy.callCount == 1)
  }

  // MARK: Private

  private actor FetchSpy {
    private(set) var callCount = 0

    func fetch(result: String) -> String {
      callCount += 1
      return result
    }
  }

  private static let referenceDate = Date(timeIntervalSince1970: 1_000_000)

  private let key = "key"
  private let otherKey = "otherKey"

  private let value = "value"
  private let otherValue = "otherValue"

  private let checkpoint = TestCheckpoint()

  private let cacheManager: CacheManager<String>
  private let fetchSpy = FetchSpy()

}
