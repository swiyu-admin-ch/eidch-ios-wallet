import Foundation

public enum DateFormat: String, CaseIterable {
  case dateTimeTimeZoneSecondsFractional = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
  case dateTimeTimeZoneSeconds = "yyyy-MM-dd'T'HH:mm:ssZ"
  case dateTimeTimeZone = "yyyy-MM-dd'T'HH:mmZ"
  case dateTimeSecondsFractional = "yyyy-MM-dd'T'HH:mm:ss.SSS"
  case dateTimeSeconds = "yyyy-MM-dd'T'HH:mm:ss"
  case dateTime = "yyyy-MM-dd'T'HH:mm"
  case dateTimeZone = "yyyy-MM-ddZ"
  case date = "yyyy-MM-dd"
  case timeTimeZoneSecondsFractional = "HH:mm:ss.SSSZ"
  case timeTimeZoneSeconds = "HH:mm:ssZ"
  case timeTimeZone = "HH:mmZ"
  case timeSecondsFractional = "HH:mm:ss.SSS"
  case timeSeconds = "HH:mm:ss"
  case time = "HH:mm"
  case yearMonth = "yyyy-MM"
  case year = "yyyy"

  // MARK: Public

  public var hasDate: Bool {
    rawValue.contains("yyyy-MM-dd")
  }

  public var hasTime: Bool {
    rawValue.contains("HH:mm")
  }

  public var hasSeconds: Bool {
    rawValue.contains("ss")
  }

  public var hasTimeZone: Bool {
    rawValue.contains("Z")
  }
}
