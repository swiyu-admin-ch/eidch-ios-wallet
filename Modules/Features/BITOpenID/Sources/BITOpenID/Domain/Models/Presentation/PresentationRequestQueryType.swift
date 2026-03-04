import AnyCodable
import Foundation

// MARK: - PresentationRequestQueryType

public enum PresentationRequestQueryType: Codable, Equatable {
  case presentationDefinition(PresentationDefinition)
  case dcqlRaw(Data)

  // MARK: Lifecycle

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if container.contains(.dcqlQuery) {
      do {
        let anyValue = try container.decode(AnyCodable.self, forKey: .dcqlQuery)
        let payload = try JSONEncoder().encode(anyValue)
        self = .dcqlRaw(payload)
      } catch {
        throw RequestObjectError.invalidDcqlQuery
      }
      return
    }

    if container.contains(.presentationDefinition) {
      let definition = try container.decode(PresentationDefinition.self, forKey: .presentationDefinition)
      self = .presentationDefinition(definition)
      return
    }

    throw RequestObjectError.missingQueryType
  }

  // MARK: Public

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .presentationDefinition(let definition):
      try container.encode(definition, forKey: .presentationDefinition)
    case .dcqlRaw(let data):
      do {
        let anyValue = try JSONDecoder().decode(AnyCodable.self, from: data)
        try container.encode(anyValue, forKey: .dcqlQuery)
      } catch {
        throw RequestObjectError.invalidDcqlQuery
      }
    }
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case presentationDefinition = "presentation_definition"
    case dcqlQuery = "dcql_query"
  }

}
