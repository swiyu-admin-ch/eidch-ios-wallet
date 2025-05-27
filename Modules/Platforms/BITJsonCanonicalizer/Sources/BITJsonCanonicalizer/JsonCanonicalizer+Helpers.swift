import Foundation

extension JsonCanonicalizer {
  func escapeJSONString(_ string: String) -> String {
    var result = ""

    for scalar in string.unicodeScalars {
      switch scalar.value {
      case 0x08: result += "\\b" // backspace
      case 0x09: result += "\\t" // tab
      case 0x0A: result += "\\n" // line feed
      case 0x0C: result += "\\f" // form feed
      case 0x0D: result += "\\r" // carriage return
      case 0x22: result += "\\\"" // quotation mark
      case 0x5C: result += "\\\\" // backslash
      case 0x2F: result += "/" // forward slash
      case 0x00...0x1F: // ASCII control characters
        let hex = String(scalar.value, radix: 16, uppercase: false)
        let padding = String(repeating: "0", count: 4 - hex.count)
        result += "\\u\(padding)\(hex)"
      default:
        result.unicodeScalars.append(scalar)
      }
    }

    return result
  }
}
