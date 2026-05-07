import Foundation

// MARK: - AuthorizationResponse

/// https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-response
public struct AuthorizationResponse: DictionarySerializable, Equatable {

  // MARK: Lifecycle

  public init(vpToken: String, presentationSubmission: PresentationSubmission) {
    self.vpToken = vpToken
    self.presentationSubmission = presentationSubmission
    vpTokenByCredentialQueryId = nil
    responseMode = nil
  }

  public init(vpTokenByCredentialQueryId: [String: [String]], responseMode: RequestObject.ResponseMode? = nil) {
    vpToken = nil
    presentationSubmission = nil
    self.vpTokenByCredentialQueryId = vpTokenByCredentialQueryId
    self.responseMode = responseMode
  }

  // MARK: Public

  public func asDictionary() -> [String: Any] {
    do {
      let encoder = JSONEncoder()
      encoder.keyEncodingStrategy = .convertToSnakeCase

      var dictionary = [String: Any]()

      if let vpToken {
        dictionary["vp_token"] = vpToken
        if let presentationSubmission {
          guard let presentationSubmissionString = try String(data: encoder.encode(presentationSubmission), encoding: .utf8) else {
            return dictionary
          }
          dictionary["presentation_submission"] = presentationSubmissionString
        }
        return dictionary
      }

      if let vpTokenByCredentialQueryId {
        if responseMode == .dcApiJWT {
          dictionary["vp_token"] = vpTokenByCredentialQueryId
          return dictionary
        }

        guard let vpTokenByCredentialQueryIdString = try String(data: encoder.encode(vpTokenByCredentialQueryId), encoding: .utf8) else {
          return dictionary
        }
        dictionary["vp_token"] = vpTokenByCredentialQueryIdString
        return dictionary
      }

      return [:]
    } catch {
      return [:]
    }
  }

  // MARK: Internal

  let vpToken: String?
  let presentationSubmission: PresentationSubmission?
  let vpTokenByCredentialQueryId: [String: [String]]?

  // MARK: Private

  private let responseMode: RequestObject.ResponseMode?
}

extension AuthorizationResponse {

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
