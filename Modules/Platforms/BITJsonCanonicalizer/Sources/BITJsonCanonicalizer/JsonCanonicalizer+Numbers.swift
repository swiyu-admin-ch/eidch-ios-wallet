import Foundation

extension JsonCanonicalizer {

  // MARK: Internal

  static let minThreshold = 1e-6
  static let maxThreshold = 1e21

  func canonicalizeNumber(_ number: NSNumber) throws -> String {
    guard isValid(number) else {
      throw JsonCanonicalizerError.infiniteNumberNotPermitted
    }

    if isBoolean(number) {
      return formatBoolean(number)
    }

    if isNegativeZero(number) {
      return "-0"
    }

    if isInteger(number) {
      return formatInteger(number)
    }

    return formatDouble(number)
  }

  // MARK: Private

  // MARK: - Validation Methods

  private func isValid(_ number: NSNumber) -> Bool {
    !(number.doubleValue.isInfinite || number.doubleValue.isNaN)
  }

  private func isBoolean(_ number: NSNumber) -> Bool {
    CFGetTypeID(number) == CFBooleanGetTypeID()
  }

  private func isNegativeZero(_ number: NSNumber) -> Bool {
    let doubleValue = number.doubleValue
    return doubleValue == 0 && (1 / doubleValue).isInfinite && (1 / doubleValue) < 0
  }

  private func isInteger(_ number: NSNumber) -> Bool {
    floor(number.doubleValue) == number.doubleValue &&
      number.doubleValue >= Double(Int64.min) &&
      number.doubleValue <= Double(Int64.max)
  }

  // MARK: - Formatting Methods

  private func formatBoolean(_ number: NSNumber) -> String {
    number.boolValue ? "true" : "false"
  }

  private func formatInteger(_ number: NSNumber) -> String {
    "\(number.int64Value)"
  }

  private func formatDouble(_ number: NSNumber) -> String {
    let doubleValue = number.doubleValue
    let absValue = abs(doubleValue)

    // Use scientific notation for very small or very large numbers
    if absValue < Self.minThreshold || absValue >= Self.maxThreshold {
      return formatScientific(doubleValue)
    }
    return formatDecimal(doubleValue)
  }

  private func formatScientific(_ value: Double) -> String {
    let sign = value < 0 ? "-" : ""
    let absValue = abs(value)
    let exponent = floor(log10(absValue))
    let normalizedMantissa = absValue / pow(10, exponent)

    let result = String(format: "%@%.16g", sign, normalizedMantissa)

    // Add exponent part in ECMAScript format
    let exponentStr = String(format: "e%+d", Int(exponent))

    if result.contains("e") {
      return result
    }
    return result + exponentStr
  }

  private func formatDecimal(_ value: Double) -> String {
    var result = "\(value)"

    // ECMAScript requires at least one digit after decimal point
    if !result.contains(".") {
      result += ".0"
    }

    // Remove trailing zeros but ensure we have at least one digit after decimal point
    if let dotIndex = result.firstIndex(of: ".") {
      let afterDot = result[result.index(after: dotIndex)...]
      if afterDot.allSatisfy({ $0 == "0" }) {
        // If all digits after dot are zeros, keep only one zero
        result = String(result[..<result.index(after: dotIndex)]) + "0"
      } else {
        // Remove trailing zeros while keeping at least one digit after decimal
        while result.last == "0" && result.filter({ $0 == "." }).count == 1 {
          let secondLastChar = result[result.index(before: result.index(before: result.endIndex))]
          if secondLastChar == "." {
            // Stop if removing would leave no digits after decimal
            break
          }
          result.removeLast()
        }
      }
    }

    return result
  }
}
