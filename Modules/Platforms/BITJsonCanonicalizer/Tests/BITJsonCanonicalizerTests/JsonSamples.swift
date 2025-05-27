import Foundation

// MARK: - JsonSample

// swiftlint:disable force_unwrapping

/// Examples based on validated input & outputs: https://github.com/cyberphone/json-canonicalization/tree/master/testdata
enum JsonSample: String {
  case arrays
  case structures
  case unicode
  case french
  case values
  case weird
  case complex

  // MARK: Internal

  func input() throws -> String {
    try JsonHelper.getJsonString(fromFile: "input-\(rawValue)")
  }

  func output() throws -> String {
    try JsonHelper.getJsonString(fromFile: "output-\(rawValue)")
  }

  func outputHex() throws -> Data {
    try JsonHelper.getJsonString(fromFile: "output-hex-\(rawValue)", ext: "txt", removeSpaces: true).data(using: .utf8)!
  }
}

// MARK: - JsonHelper

struct JsonHelper {

  enum JsonHelperError: Error {
    case notFound
    case cannotReadFile
  }

  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()

  static func getJsonString(fromFile filename: String, ext: String = "json", removeSpaces: Bool = false) throws -> String {
    guard let fileUrl = bundle.url(forResource: filename, withExtension: ext) else { throw JsonHelperError.notFound }
    do {
      var string = try String(contentsOf: fileUrl, encoding: .utf8)
      if removeSpaces {
        string = string.replacingOccurrences(of: " ", with: "")
      }
      return string.replacingOccurrences(of: "\n", with: "")
    } catch {
      throw JsonHelperError.cannotReadFile
    }
  }

}

// swiftlint:enable force_unwrapping
