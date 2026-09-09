import Foundation

actor TestCheckpoint {
  private var continuations = [CheckedContinuation<Void, Never>]()

  func pause() async {
    await withCheckedContinuation { continuation in
      continuations.append(continuation)
    }
  }

  func waitUntilPausedTasks(count: Int) async {
    while continuations.count < count {
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
