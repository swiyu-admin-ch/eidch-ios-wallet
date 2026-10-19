import Factory
import Foundation

// MARK: - CacheManager

public actor CacheManager<Value: Sendable> {

  public init(defaultTimeToLive: TimeInterval = 5 * 60) {
    self.defaultTimeToLive = defaultTimeToLive
  }

  public func get(
    for key: some Hashable,
    timeToLive: TimeInterval? = nil,
    fetch: @escaping @Sendable () async throws -> Value) async throws
    -> Value
  {
    let key = AnyHashable(key)
    if let cached = getCachedValue(for: key) {
      return cached
    }

    if let task = inFlightTasks[key] {
      #if DEBUG
      inFlightWaiterCount += 1
      defer { inFlightWaiterCount -= 1 }
      #endif
      return try await task.value
    }

    return try await fetchAndCache(
      key: key,
      timeToLive: timeToLive ?? defaultTimeToLive,
      fetch: fetch)
  }

  public func invalidateAll() {
    for task in inFlightTasks.values {
      task.cancel()
    }

    cache.removeAll()
    inFlightTasks.removeAll()
  }

  private let defaultTimeToLive: TimeInterval

  private var cache = [AnyHashable: CacheEntry]()
  private var inFlightTasks = [AnyHashable: Task<Value, Error>]()
  #if DEBUG
  private(set) var inFlightWaiterCount = 0 // only for testing
  #endif
}

extension CacheManager {

  fileprivate struct CacheEntry {
    let value: Value
    let expirationDate: Date

    var isExpired: Bool {
      Container.shared.currentDate() >= expirationDate
    }
  }

  fileprivate func getCachedValue(for key: AnyHashable) -> Value? {
    guard let entry = cache[key] else { return nil }
    guard !entry.isExpired else {
      cache.removeValue(forKey: key)
      return nil
    }
    return entry.value
  }

  fileprivate func fetchAndCache(
    key: AnyHashable,
    timeToLive: TimeInterval,
    fetch: @escaping @Sendable () async throws -> Value) async throws
    -> Value
  {
    let task = Task<Value, Error> {
      try await fetch()
    }

    inFlightTasks[key] = task
    defer { inFlightTasks.removeValue(forKey: key) }

    let value = try await task.value
    store(value, for: key, timeToLive: timeToLive)
    return value
  }

  fileprivate func store(
    _ value: Value,
    for key: AnyHashable,
    timeToLive: TimeInterval)
  {
    let expirationDate = Container.shared.currentDate()
      .addingTimeInterval(timeToLive)
    cache[key] = CacheEntry(
      value: value,
      expirationDate: expirationDate)
  }
}

extension CacheManager {
  public func get(
    for type: Value.Type,
    timeToLive: TimeInterval? = nil,
    fetch: @escaping @Sendable () async throws -> Value) async throws
    -> Value
  {
    try await get(
      for: ObjectIdentifier(type),
      timeToLive: timeToLive,
      fetch: fetch)
  }
}
