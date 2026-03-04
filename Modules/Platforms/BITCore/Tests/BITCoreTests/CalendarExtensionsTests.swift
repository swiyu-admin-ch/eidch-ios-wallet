import Foundation
import XCTest
@testable import BITCore

final class CalendarExtensionsTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    setenv("TZ", "UTC", 1)
    CFTimeZoneResetSystem()
  }

  override func tearDown() {
    unsetenv("TZ")
    CFTimeZoneResetSystem()
  }

  func testNumberOfDaysBetween_sameDay_Returns0() {
    let fromDate = midnightDate
    let toDate = fromDate.advanced(by: 1)

    let days = calendar.numberOfDaysBetween(fromDate, and: toDate)

    XCTAssertEqual(days, 0)
  }

  func testNumberOfDaysBetween_fromMidnightToSameDayBeforeMidnight_Returns0() {
    let fromDate = midnightDate
    let toDate = fromDate.advanced(by: Self.secondsPerDay - 1)

    let days = calendar.numberOfDaysBetween(fromDate, and: toDate)

    XCTAssertEqual(days, 0)
  }

  func testNumberOfDaysBetween_from11PMToSameDayBeforeMidnight_Returns0() {
    let fromDate = elevenPMDate
    let toDate = fromDate.advanced(by: Self.secondsPerHour - 1)

    let days = calendar.numberOfDaysBetween(fromDate, and: toDate)

    XCTAssertEqual(days, 0)
  }

  func testNumberOfDaysBetween_fromMidnightToNextDayAfterMidnight_Returns1() {
    let fromDate = midnightDate
    let toDate = fromDate.advanced(by: Self.secondsPerDay + 1)

    let days = calendar.numberOfDaysBetween(fromDate, and: toDate)

    XCTAssertEqual(days, 1)
  }

  func testNumberOfDaysBetween_from11PMToNextDayAfterMidnight_Returns1() {
    let fromDate = elevenPMDate
    let toDate = fromDate.advanced(by: Self.secondsPerHour + 1)

    let days = calendar.numberOfDaysBetween(fromDate, and: toDate)

    XCTAssertEqual(days, 1)
  }

  func testNumberOfDaysBetween_fromMidnightToNextDayBeforeMidnight_Returns1() {
    let fromDate = midnightDate
    let toDate = fromDate.advanced(by: Self.secondsPerDay * 2 - 1)

    let days = calendar.numberOfDaysBetween(fromDate, and: toDate)

    XCTAssertEqual(days, 1)
  }

  func testNumberOfDaysBetween_from11PMToNextDayBeforeMidnight_Returns1() {
    let fromDate = elevenPMDate
    let toDate = fromDate.advanced(by: Self.secondsPerDay + Self.secondsPerHour - 1)

    let days = calendar.numberOfDaysBetween(fromDate, and: toDate)

    XCTAssertEqual(days, 1)
  }

  func testNumberOfDaysBetween_fromMidnightToInAWeek_Returns7() {
    let fromDate = midnightDate
    let toDate = fromDate.advanced(by: Self.secondsPerDay * 7 + 1)

    let days = calendar.numberOfDaysBetween(fromDate, and: toDate)

    XCTAssertEqual(days, 7)
  }

  func testNumberOfDaysBetween_from11PMToInAWeek_Returns7() {
    let fromDate = elevenPMDate
    let toDate = fromDate.advanced(by: Self.secondsPerDay * 6 + Self.secondsPerHour + 1)

    let days = calendar.numberOfDaysBetween(fromDate, and: toDate)

    XCTAssertEqual(days, 7)
  }

  // MARK: Private

  private static let secondsPerHour: Double = 60 * 60
  private static let secondsPerDay: Double = secondsPerHour * 24

  private lazy var calendar = Calendar(identifier: .iso8601)

  private lazy var midnightDate: Date = calendar.startOfDay(for: Date())

  private lazy var elevenPMDate: Date = calendar.startOfDay(for: Date()).advanced(by: Self.secondsPerHour * 23)

}
