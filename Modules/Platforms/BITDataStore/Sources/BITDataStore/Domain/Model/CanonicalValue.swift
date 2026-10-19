import BITCrypto
import Factory
import Foundation

// MARK: - CanonicalValue

/// Intermediate representation of a Hashed object, used to compute its content hash.
///
/// `ContentHasher` converts an object and its children into a `CanonicalValue` tree, then hashes
/// ``canonicalString`` to get the `contentHash` primary key. Two objects with the same content
/// produce the same hash and are stored on the same row.
indirect enum CanonicalValue {
  case string(String)
  case int(Int)
  case bool(Bool)
  case date(Date)
  case bytes(Data)
  case array([CanonicalValue])
  case dictionary([String: CanonicalValue])

  // MARK: Internal

  /// The deterministic string representation of the value, hashed to produce the content hash.
  ///
  /// - Each case is prefixed with a type tag, so two values of different types never produce the
  /// same string.
  /// - Strings carry their UTF-8 length, so a value containing `,` or `=` cannot be read as a field
  /// separator.
  /// - Arrays are sorted: element order is not part of the content.
  /// - Data is represented by its digest, to keep the string at a fixed size.
  ///
  /// IMPORTANT: This format is persisted as a primary key: changing it invalidates every stored `contentHash`
  /// and requires a migration that rehashes the rows to the new format you are trying to have.
  var canonicalString: String {
    switch self {
    case .string(let value):
      "s:\(value.utf8.count):\(value)"
    case .int(let value):
      "i:\(value)"
    case .bool(let value):
      "b:\(value ? 1 : 0)"
    case .date(let value):
      "d:\(Int((value.timeIntervalSince1970 * 1000).rounded()))"
    case .bytes(let value):
      "x:\(CanonicalValue.digest(value))"
    case .array(let values):
      "l:[" + values.map(\.canonicalString).sorted().joined(separator: ",") + "]"
    case .dictionary(let fields):
      "o:{" + fields.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value.canonicalString)" }.joined(separator: ",") + "}"
    }
  }

  static func digest(_ data: Data) -> String {
    Container.shared.sha256Hasher().hash(data).hexString
  }
}
