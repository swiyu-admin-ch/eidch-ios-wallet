import Foundation

// MARK: - PresentationRequestBody

public struct PresentationRequestBody: Codable, Equatable {

  // MARK: Lifecycle

  public init(vpToken: String, presentationSubmission: PresentationSubmission) {
    self.vpToken = vpToken
    self.presentationSubmission = presentationSubmission
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    vpToken = try container.decode(String.self, forKey: .vpToken)
    presentationSubmission = try container.decode(PresentationRequestBody.PresentationSubmission.self, forKey: .presentationSubmission)
  }

  // MARK: Public

  public func asDictionary() -> [String: Any] {
    do {
      let encoder = JSONEncoder()
      encoder.keyEncodingStrategy = .convertToSnakeCase

      var dictionary = [String: Any?]()
      dictionary["vp_token"] = vpToken

      guard let presentationSubmissionString = try String(data: encoder.encode(presentationSubmission), encoding: .utf8) else {
        return dictionary.compactMapValues { $0 }
      }

      dictionary["presentation_submission"] = presentationSubmissionString

      return dictionary.compactMapValues { $0 }
    } catch {
      return [:]
    }
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case vpToken = "vp_token"
    case presentationSubmission = "presentation_submission"
  }

  let vpToken: String
  let presentationSubmission: PresentationSubmission
}

extension PresentationRequestBody {

  public struct DescriptorMap: Codable, Equatable {
    let id: String
    let format: String
    let path: String

    public init(id: String, format: String, path: String) {
      self.id = id
      self.format = format
      self.path = path
    }
  }

  public struct PresentationSubmission: Codable, Equatable {
    let id: String
    let definitionId: String
    let descriptorMap: [DescriptorMap]

    public init(id: String, definitionId: String, descriptorMap: [DescriptorMap]) {
      self.id = id
      self.definitionId = definitionId
      self.descriptorMap = descriptorMap
    }

    enum CodingKeys: String, CodingKey {
      case id
      case definitionId = "definition_id"
      case descriptorMap = "descriptor_map"
    }
  }

}
