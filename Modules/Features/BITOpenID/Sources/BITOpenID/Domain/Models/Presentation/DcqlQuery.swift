import AnyCodable
import BITSwiyuSharedKMP
import Foundation

public struct DcqlQuery: Codable, Equatable {

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
