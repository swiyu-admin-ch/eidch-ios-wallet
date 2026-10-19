import Foundation

actor TestCheckpoint {
  private var continuations = [CheckedContinuation<Void, Never>]()
  private(set) var totalPauseCount = 0

  var pausedCount: Int {
    continuations.count
  }

  func pause() async {
    totalPauseCount += 1
    await withCheckedContinuation { continuation in
      continuations.append(continuation)
    }
  }

  func waitUntilPausedTasks(count: Int) async {
    while continuations.count < count {
      await Task.yield()
    }
  }

  func waitUntilTotalPausedTasks(count: Int) async {
    while totalPauseCount < count {
      await Task.yield()
    }
  }

  func resumeNext() {
    guard !continuations.isEmpty else { return }
    continuations.removeFirst().resume()
  }

  func resumeAll() {
    let current = continuations
    continuations.removeAll()

    for continuation in current {
      continuation.resume()
    }
  }
}
