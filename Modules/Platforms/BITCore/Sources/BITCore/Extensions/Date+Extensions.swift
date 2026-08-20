import Foundation

extension Date {

  public var longDateFormat: String {
    formatted(date: .long, time: .omitted)
  }

  public static func create(_ year: Int, _ month: Int, _ day: Int) -> Date {
    create(year, month, day, 0, 0, 0)
  }

  public static func create(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int, _ second: Int) -> Date {
    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = month
    dateComponents.day = day
    dateComponents.hour = hour
    dateComponents.minute = minute
    dateComponents.second = second

    let userCalendar = Calendar(identifier: .gregorian)

    guard let date = userCalendar.date(from: dateComponents) else {
      return Date()
    }

    return date
  }

  public static func today(_ hour: Int, _ minute: Int, _ second: Int) -> Date {
    var dateComponents = DateComponents()
    dateComponents.hour = hour
    dateComponents.minute = minute
    dateComponents.second = second

    let userCalendar = Calendar(identifier: .gregorian)

    guard let date = userCalendar.date(from: dateComponents) else {
      return Date()
    }

    return date
  }

  public func dayOfWeekAsNumber() -> Int? {
    Calendar.current.dateComponents([.weekday], from: self).weekday
  }

  public func dayOfWeek() -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    return dateFormatter.string(from: self)
  }

}
