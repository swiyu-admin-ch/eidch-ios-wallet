import Foundation
import Testing
@testable import BITCore
@testable import BITTestingCore

@Suite
struct ConcurrentMapLimitedTests {

  @Test
  func concurrentMapLimited_whenCollectionIsEmpty_returnsEmptyArray() async {
    let list = [Int]()

    let result = await list.concurrentMapLimited(maxConcurrentTasks: 1, { $0 })

    #expect(result.isEmpty)
  }

  @Test
  func concurrentMapLimited_whenTasksCompleteOutOfOrder_preservesInputOrder() async {
    let first = TestCheckpoint()
    let second = TestCheckpoint()
    let third = TestCheckpoint()

    let checkpoints = [first, second, third]
    let list = [1, 2, 3]

    let task = Task {
      await list.concurrentMapLimited(maxConcurrentTasks: 3) {
        await checkpoints[$0 - 1].pause()
        return $0
      }
    }

    await first.waitUntilPausedTasks(count: 1)
    await second.waitUntilPausedTasks(count: 1)
    await third.waitUntilPausedTasks(count: 1)

    await second.resumeAll()
    await third.resumeAll()
    await first.resumeAll()

    let result = await task.value

    #expect(result.count == 3)
    result[0].expectSuccess(1)
    result[1].expectSuccess(2)
    result[2].expectSuccess(3)
  }

  @Test
  func concurrentMapLimited_whenTransformThrows_returnsFailureForCorrespondingElement() async {
    let list = [1, 2, 3]

    let result = await list.concurrentMapLimited(maxConcurrentTasks: 2) {
      if $0 == 2 {
        throw TestingError.error
      }
      return $0
    }

    #expect(result.count == 3)
    result[0].expectSuccess(1)
    result[1].expectFailure(TestingError.self)
    result[2].expectSuccess(3)
  }

  @Test
  func concurrentMapLimited_whenMaxConcurrentTasksExceedsElementCount_returnsAllResults() async {
    let list = [1, 2]

    let result = await list.concurrentMapLimited(maxConcurrentTasks: 10) { $0 }

    #expect(result.count == 2)
    result[0].expectSuccess(1)
    result[1].expectSuccess(2)
  }

  @Test
  func concurrentMapLimited_whenLimitIsTwo_runsAtMostTwoTasksSimultaneously() async {
    let checkpoint = TestCheckpoint()
    let list = [1, 2, 3, 4]

    let task = Task {
      await list.concurrentMapLimited(maxConcurrentTasks: 2) {
        await checkpoint.pause()
        return $0
      }
    }

    await checkpoint.waitUntilPausedTasks(count: 2)
    await checkpoint.resumeNext()
    await checkpoint.waitUntilTotalPausedTasks(count: 3)
    #expect(await checkpoint.pausedCount == 2)
    await checkpoint.resumeNext()
    await checkpoint.waitUntilTotalPausedTasks(count: 4)
    await checkpoint.resumeAll()
    let result = await task.value

    #expect(result.count == 4)
    result[0].expectSuccess(1)
    result[1].expectSuccess(2)
    result[2].expectSuccess(3)
    result[3].expectSuccess(4)
  }

  @Test
  func concurrentMapLimited_whenMaxConcurrentTasksIsOne_runsTasksSequentially() async {
    let checkpoint = TestCheckpoint()
    let list = [1, 2, 3]

    let task = Task {
      await list.concurrentMapLimited(maxConcurrentTasks: 1) {
        await checkpoint.pause()
        return $0
      }
    }

    for i in 1...3 {
      await checkpoint.waitUntilPausedTasks(count: 1)
      #expect(await checkpoint.pausedCount == 1)
      await checkpoint.resumeNext()
    }

    let result = await task.value

    #expect(result.count == 3)
    result[0].expectSuccess(1)
    result[1].expectSuccess(2)
    result[2].expectSuccess(3)
  }

  @Test
  func concurrentMapLimited_whenCancelledBeforePendingTasksStart_returnsCancellationFailures() async {
    let checkpoint = TestCheckpoint()
    let list = [1, 2, 3]

    let task = Task {
      await list.concurrentMapLimited(maxConcurrentTasks: 1) {
        await checkpoint.pause()
        return $0
      }
    }

    await checkpoint.waitUntilPausedTasks(count: 1)
    task.cancel()
    await checkpoint.resumeAll()
    let result = await task.value

    #expect(result.count == 3)
    result[0].expectSuccess(1)
    result[1].expectFailure(CancellationError.self)
    result[2].expectFailure(CancellationError.self)
  }
}
