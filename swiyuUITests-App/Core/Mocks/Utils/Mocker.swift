import BITJWT
import BITOpenID
import Foundation

// MARK: - Mocker

// swiftlint:disable force_unwrapping

struct Mocker {

  static func decode<T: Decodable>(fromFile filename: String, ofType ext: String = "json", dateFormatter: JSONDecoder.DateDecodingStrategy = .iso8601, bundle: Bundle = Bundle.main) -> T {
    guard let data = getData(fromFile: filename, ofType: ext, bundle: bundle) else { fatalError("Can't generate Data from the mocked file. File: \(filename).\(ext)") }
    return decode(fromData: data, dateFormatter: dateFormatter)
  }

  static func decodeRawText(fromFile filename: String, bundle: Bundle = Bundle.main) -> JWS<TokenStatusList> {
    guard let fileURL = bundle.url(forResource: filename, withExtension: "txt")
    else { fatalError("Impossible to read \(filename)") }
    let decoder = JWSDecoder()
    do {
      let rawString = try String(contentsOf: fileURL, encoding: .utf8)
        .replacingOccurrences(of: "\n", with: "")
        .replacingOccurrences(of: "\"", with: "")
      return try decoder.decode(TokenStatusList.self, from: rawString.data(using: .utf8)!)
    }
    catch { fatalError("Error reading the file: \(error.localizedDescription)") }
  }

  static func decodeRawText(fromFile filename: String, bundle: Bundle = Bundle.main) -> String {
    guard let fileURL = bundle.url(forResource: filename, withExtension: "txt") else {
      fatalError("Impossible to read \(filename)")
    }

    do {
      return try String(contentsOf: fileURL, encoding: .utf8).replacingOccurrences(of: "\n", with: "")
    } catch {
      fatalError("Error reading the file: \(error.localizedDescription)")
    }
  }

  static func decode<T: Decodable>(fromData data: Data, dateFormatter: JSONDecoder.DateDecodingStrategy = .iso8601) -> T {
    do {
      let object: T = try JSONDecoder.decode(data, dateFormat: dateFormatter)
      return object
    } catch {
      fatalError("Can't decode object: \(error)")
    }
  }

  static func getData(fromFile filename: String, ofType ext: String = "json", bundle: Bundle = Bundle.main) -> Data? {
    guard let path = bundle.path(forResource: filename, ofType: ext) else {
      fatalError("Can't find the bundle path. File: \(filename).\(ext)")
    }

    do {
      let text = try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8).replacingOccurrences(of: "\n", with: "")
      return text.data(using: .utf8) ?? Data()
    } catch {
      fatalError("Error reading the file: \(error.localizedDescription)")
    }
  }

}

extension JSONDecoder {

  static func decode<D: Decodable>(_ data: Data, dateFormat: JSONDecoder.DateDecodingStrategy = .iso8601) throws -> D {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = dateFormat
    return try decoder.decode(D.self, from: data)
  }

  static func decode<T: Decodable>(from string: String, onDecodingError error: Error) throws -> T {
    guard let data = string.data(using: .utf8) else { throw error }
    return try JSONDecoder().decode(T.self, from: data)
  }

}

// swiftlint:enable all
