import Foundation

// MARK: - ConcurrencyTracker

public actor ConcurrencyTracker {

  private(set) var maxActiveTaskCount = 0

  public func track<T>(_ task: () -> T) async -> T {
    activeTaskCount += 1
    defer { activeTaskCount -= 1 }
    maxActiveTaskCount = max(maxActiveTaskCount, activeTaskCount)

    await checkpoint.pause()

    return task()
  }

  public func waitUntilPausedTasks(count: Int) async {
    await checkpoint.waitUntilPausedTasks(count: count)
  }

  public func resumeAll() async {
    await checkpoint.resumeAll()
  }

  private var activeTaskCount = 0
  private let checkpoint = TestCheckpoint()
}
