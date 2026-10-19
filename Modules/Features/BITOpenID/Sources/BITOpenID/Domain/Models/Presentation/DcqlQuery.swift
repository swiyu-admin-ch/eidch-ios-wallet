import AnyCodable
import BITSwiyuSharedKMP
import Foundation

/// `query` is a Kotlin Multiplatform class that cannot be annotated here. It is decoded once in
/// `init(from:)` and never mutated afterwards, which is what makes the unchecked conformance sound.
public struct DcqlQuery: Codable, Equatable, @unchecked Sendable {

  // MARK: Lifecycle

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let any = try container.decode(AnyCodable.self)
    let data = try JSONEncoder().encode(any)

    guard let json = String(data: data, encoding: .utf8) else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Failed to convert DCQL JSON")
    }

    query = try DcqlSupport().decodeDcqlQuery(json: json)
  }

  // MARK: Public

  public let query: Heidi_dcqlDcqlQuery

  public func encode(to encoder: Encoder) throws {
    let container = encoder.singleValueContainer()
    throw EncodingError.invalidValue(
      query,
      EncodingError.Context(
        codingPath: container.codingPath,
        debugDescription: "Failed to convert DCQL JSON string to Data"))

  }

}
