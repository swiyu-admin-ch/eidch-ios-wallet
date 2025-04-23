#if DEBUG
import Foundation

// MARK: - Mockable

public protocol Mockable {
  static func decode<T: Decodable>(fromFile filename: String, ofType ext: String, dateFormatter: JSONDecoder.DateDecodingStrategy, bundle: Bundle) -> T
}

// MARK: - Mocker

public struct Mocker: Mockable {}
extension Mockable {

  public static func getData(fromFile filename: String, ofType ext: String = "json", bundle: Bundle = Bundle.main) -> Data? {
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

  public static func getString(fromFile filename: String, ofType ext: String = "txt", bundle: Bundle = Bundle.main) -> String {
    guard let fileURL = bundle.url(forResource: filename, withExtension: ext)
    else { fatalError("Impossible to read \(filename)") }
    do {
      return try String(contentsOf: fileURL, encoding: .utf8).replacingOccurrences(of: "\n", with: "")
    } catch { fatalError("Error reading the file: \(error.localizedDescription)") }
  }

  public static func decode<T: Decodable>(fromFile filename: String, ofType ext: String = "json", dateFormatter: JSONDecoder.DateDecodingStrategy = .iso8601, bundle: Bundle = Bundle.main) -> T {
    guard let data = getData(fromFile: filename, ofType: ext, bundle: bundle) else { fatalError("Can't generate Data from the mocked file. File: \(filename).\(ext)") }
    return decode(fromData: data, dateFormatter: dateFormatter)
  }

  public static func decode<T: Decodable>(fromData data: Data, dateFormatter: JSONDecoder.DateDecodingStrategy = .iso8601) -> T {
    do {
      let object: T = try JSONDecoder.decode(data, dateFormat: dateFormatter)
      return object
    } catch {
      fatalError("Can't decode object: \(error)")
    }
  }

}
#endif
