import Foundation

extension TimeInterval {

  public static func days(_ value: Double) -> TimeInterval {
    value * 24 * 60 * 60
  }
}
