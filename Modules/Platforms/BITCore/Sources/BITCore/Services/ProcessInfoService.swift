import Foundation
import Spyable

// MARK: - ProcessInfoServiceProtocol

@Spyable
public protocol ProcessInfoServiceProtocol: Sendable {
  var systemUptime: TimeInterval { get }
}

// MARK: - ProcessInfoService

struct ProcessInfoService: ProcessInfoServiceProtocol {
  var systemUptime: TimeInterval {
    // use clock monotonic as it ticks even when phone is in sleep state
    var timeSpec = timespec()
    clock_gettime(CLOCK_MONOTONIC, &timeSpec)
    return TimeInterval(timeSpec.tv_sec)
  }
}
