import Foundation
import RealmSwift

// MARK: - ContentHasherProtocol

/// Computes the `contentHash` used as primary key by the content hashed entities, so that two
/// objects with the same content are stored once and resolved through `resolvedByContentHash(in:)`.
public protocol ContentHasherProtocol: Sendable {
  /// Computes the content hash of the object and of its children.
  ///
  /// - Parameter object: the object to hash
  /// - Returns: The content hash, as a hexadecimal SHA-256 string
  func hash(_ object: Object) -> String

  /// Whether the object is keyed by its content rather than by an identifier.
  ///
  /// - Parameter object: the object to inspect
  func isContentHashed(_ object: Object) -> Bool
}

// MARK: - ContentHasher

/// The properties are read from the object schema rather than declared here, so a new column is
/// taken into account without having to update this file. The primary key and the bookkeeping
/// columns are excluded: the same content must give the same hash, whatever its `id` or `createdAt`.
public struct ContentHasher: ContentHasherProtocol {

  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public func hash(_ object: Object) -> String {
    CanonicalValue.digest(Data(canonicalValue(of: object).canonicalString.utf8))
  }

  public func isContentHashed(_ object: Object) -> Bool {
    object.objectSchema.primaryKeyProperty?.name == Self.contentHashKey
  }

  // MARK: Internal

  static let contentHashKey = "contentHash"

  // MARK: Private

  private static let excludedProperties: Set<String> = [contentHashKey, "id", "createdAt"]

  /// The traversal follows whatever links the schema declares, and a self-referential table such as
  /// a cluster tree can form a cycle. Stopping at an object that is already its own ancestor cuts
  /// exactly the cycle: nesting depth is set by the issuer's OCA bundle, so bounding it instead would
  /// drop content out of the hash without saying so.
  private func canonicalValue(of object: Object, ancestors: [Object] = []) -> CanonicalValue {
    guard !ancestors.contains(where: { $0.isSameObject(as: object) }) else { return .dictionary([:]) }

    let lineage = ancestors + [object]
    var fields = [String: CanonicalValue]()

    for property in object.objectSchema.properties {
      guard property.type != .linkingObjects, !Self.excludedProperties.contains(property.name) else { continue }

      if property.objectClassName != nil {
        if property.isArray {
          fields[property.name] = .array(object.dynamicList(property.name).map { canonicalValue(of: $0, ancestors: lineage) })
        } else if let child = object[property.name] as? Object {
          fields[property.name] = canonicalValue(of: child, ancestors: lineage)
        }
      } else if !property.isArray, !property.isSet, !property.isMap {
        if let value = canonicalScalar(object[property.name]) {
          fields[property.name] = value
        }
      }
    }

    return .dictionary(fields)
  }

  /// `Bool` must be matched before `Int`: `NSNumber` bridging would otherwise hash booleans as integers.
  private func canonicalScalar(_ value: Any?) -> CanonicalValue? {
    switch value {
    case nil,
         is NSNull: nil
    case let value as String: .string(value)
    case let value as Data: .bytes(value)
    case let value as Date: .date(value)
    case let value as Bool: .bool(value)
    case let value as Int: .int(value)
    case let value as Int16: .int(Int(value))
    case let value as Int32: .int(Int(value))
    case let value as Int64: .int(Int(value))
    case let value as UUID: .string(value.uuidString)
    case let value as any RawRepresentable<String>: .string(value.rawValue)
    default: nil
    }
  }
}
