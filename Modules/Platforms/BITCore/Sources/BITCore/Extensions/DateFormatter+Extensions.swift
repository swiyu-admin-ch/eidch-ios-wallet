import Foundation

extension DateFormatter {

  // MARK: Lifecycle

  public convenience init(format: String) {
    self.init()
    dateFormat = format
  }

  // MARK: Public

  public static let longDateFormatter: DateFormatter = generateFormatter(forTemplate: "dd MMMM yyyy")
  public static let shortDateFormatter: DateFormatter = generateFormatter(forTemplate: "dd.MM.yyyy")
  public static let shortHourFormatter: DateFormatter = generateFormatter(forTemplate: "HH:mm")
  public static let yearMonthGroupedFormatter: DateFormatter = generateFormatter(forTemplate: "MMMM yyyy")

  // MARK: Private

  private static func generateFormatter(forTemplate template: String) -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.setLocalizedDateFormatFromTemplate(template)
    return dateFormatter
  }
}
