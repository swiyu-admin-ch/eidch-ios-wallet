import BITCore
import Foundation

// MARK: - RequestObjectError

enum RequestObjectError: Error {
  case invalidPayload
  case invalidInputDescriptorFormat
}

// MARK: - RequestObject

/// A srtructure representing OpenID Authorization Request
/// https://openid.net/specs/openid-4-verifiable-presentations-1_0-20.html#name-authorization-request
public class RequestObject: Decodable {

  // MARK: Lifecycle

  init(presentationDefinition: PresentationDefinition, nonce: String?, responseUri: String, clientMetadata: ClientMetadata?, responseType: String, clientId: String, clientIdScheme: String?, responseMode: String) {
    self.presentationDefinition = presentationDefinition
    self.nonce = nonce
    self.responseUri = responseUri
    self.clientMetadata = clientMetadata
    self.responseType = responseType
    self.clientId = clientId
    self.clientIdScheme = clientIdScheme
    self.responseMode = responseMode
  }

  // MARK: Public

  public let presentationDefinition: PresentationDefinition
  public let nonce: String?
  public let responseUri: String
  public let clientMetadata: ClientMetadata?
  public let responseType: String
  public let clientId: String
  public let clientIdScheme: String?
  public let responseMode: String

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case presentationDefinition = "presentation_definition"
    case nonce
    case responseUri = "response_uri"
    case clientMetadata = "client_metadata"
    case responseType = "response_type"
    case clientId = "client_id"
    case clientIdScheme = "client_id_scheme"
    case responseMode = "response_mode"
  }

}

// MARK: Equatable

extension RequestObject: Equatable {
  public static func == (lhs: RequestObject, rhs: RequestObject) -> Bool {
    lhs.responseMode == rhs.responseMode &&
      lhs.clientIdScheme == rhs.clientIdScheme &&
      lhs.clientId == rhs.clientId &&
      lhs.responseType == rhs.responseType &&
      lhs.responseUri == rhs.responseUri &&
      lhs.nonce == rhs.nonce &&
      lhs.clientMetadata == rhs.clientMetadata &&
      lhs.presentationDefinition == rhs.presentationDefinition
  }
}

public typealias Verifier = ClientMetadata

// MARK: - ClientMetadata

public struct ClientMetadata: Decodable, Equatable {

  // MARK: Lifecycle

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
    clientName = try LocalizedDisplay(from: container, withBaseKey: "client_name")
    logoUri = try LocalizedDisplay(from: container, withBaseKey: "logo_uri")
  }

  // MARK: Public

  public let clientName: LocalizedDisplay?
  public let logoUri: LocalizedDisplay?

  // MARK: Internal

  struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int? { nil }

    init?(stringValue: String) {
      self.stringValue = stringValue
    }

    init?(intValue: Int) {
      nil
    }
  }
}

// MARK: ClientMetadata.LocalizedDisplay

extension ClientMetadata {

  /// Data model providing a Hash representation of the localized display
  /// where the  key of the hash is the language in two letters form (ISO-639)
  public struct LocalizedDisplay: Decodable, Equatable {

    // MARK: Lifecycle

    init?(from container: KeyedDecodingContainer<DynamicCodingKeys>, withBaseKey baseKey: String) throws {
      for key in container.allKeys where key.stringValue.hasPrefix(baseKey) {
        let language = key.stringValue.components(separatedBy: Self.separator).dropFirst().joined(separator: Self.separator)
        if let value = try? container.decode(String.self, forKey: key) {
          values[String(language)] = value
        }
      }

      if values.isEmpty {
        return nil
      }
    }

    // MARK: Public

    /// A static helper method that retrieves the preferred display string from a set of localized displays,
    /// prioritizing the user's preferred language codes.
    ///
    /// - Returns: The best matching display string based on the preferred languages, the app's default language, or a fallback if available. Returns `nil` if no display is found.
    public static func getPreferredDisplay(from displays: LocalizedDisplay?, considering preferredUserLanguageCodes: [UserLanguageCode] ) -> String? {
      guard let displays else {
        return nil
      }

      for languageCode in preferredUserLanguageCodes {
        if let display = displays.value(for: languageCode) {
          return display
        }
      }

      if let display = displays.value(for: UserLanguageCode.defaultAppLanguageCode) {
        return display
      }

      if let display = displays.fallback() {
        return display
      }

      return nil
    }

    public func value(for locale: String) -> String? {
      values[locale]
    }

    public func fallback() -> String? {
      values[""]
    }

    // MARK: Private

    private static let separator = "#"

    private var values: [String: String] = [:]
  }
}

// MARK: - PresentationDefinition

/// https://identity.foundation/presentation-exchange/spec/v2.1.0/#presentation-definition

public struct PresentationDefinition: Decodable, Equatable {
  public let id: String
  public let name: String?
  public let purpose: String?
  public let inputDescriptors: [InputDescriptor]

  /// This format property seems to be the same as in the InputDescriptor

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case purpose
    case inputDescriptors = "input_descriptors"
  }
}

// MARK: - InputDescriptor

public struct InputDescriptor: Decodable, Equatable {

  // MARK: Lifecycle

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    name = try container.decodeIfPresent(String.self, forKey: .name)
    purpose = try container.decodeIfPresent(String.self, forKey: .purpose)
    constraints = try container.decode(Constraints.self, forKey: .constraints)

    var formats = [Format]()
    let formatContainer = try container.nestedContainer(keyedBy: Format.CodingKeys.self, forKey: .formats)

    if let vcSdJwt = try formatContainer.decodeIfPresent(VcSdJwtFormat.self, forKey: .vcSdJwt) {
      formats.append(.vcSdJwt(vcSdJwt))
    }
    if formats.isEmpty { throw RequestObjectError.invalidPayload }

    self.formats = formats
  }

  // MARK: Public

  public let id: String
  public let name: String?
  public let purpose: String?
  public let formats: [Format]
  public let constraints: Constraints

  public static func == (lhs: InputDescriptor, rhs: InputDescriptor) -> Bool {
    lhs.name == rhs.name &&
      lhs.purpose == rhs.purpose &&
      lhs.constraints == rhs.constraints &&
      lhs.id == rhs.id
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case purpose
    case formats = "format"
    case constraints
  }
}

// MARK: - Constraints

public struct Constraints: Codable, Equatable {
  public let fields: [Field]
  public let limitDisclosure: LimitDisclosure?

  enum CodingKeys: String, CodingKey {
    case fields
    case limitDisclosure = "limit_disclosure"
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    fields = try container.decode([Field].self, forKey: .fields)
    limitDisclosure = try container.decodeIfPresent(LimitDisclosure.self, forKey: .limitDisclosure)
  }
}

// MARK: - Field

public struct Field: Codable, Equatable {

  // MARK: Lifecycle

  public init(path: [String], filter: Filter? = nil, id: String? = nil, purpose: String? = nil, name: String? = nil, optional: Bool? = nil) {
    self.path = path
    self.filter = filter
    self.id = id
    self.purpose = purpose
    self.name = name
    self.optional = optional
  }

  // MARK: Public

  public let path: [String]
  public let filter: Filter?
  public let id: String?
  public let purpose: String?
  public let name: String?
  public var optional: Bool?

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case path
    case filter
    case id
    case purpose
    case name
    case optional
  }

  func isMatching(_ value: Any) -> Bool {
    guard path.contains(Self.vctPath) else { return true } // we ignore filters for paths that are not vct
    return filter?.isMatching(value) ?? true
  }

  // MARK: Private

  private static let vctPath = "$.vct"

}

// MARK: - LimitDisclosure

public enum LimitDisclosure: String, Codable, Equatable {
  case required
  case preferred
}

// MARK: - Filter

public struct Filter: Codable, Equatable {
  public let const: String?
  public let type: String

  func isMatching(_ value: Any) -> Bool {
    guard isSupported() else { return true } // we ignore unsupported filters
    guard let stringValue = value as? String else { return false }
    return stringValue == const
  }

  private func isSupported() -> Bool {
    guard type == Self.stringType, let const else { return false }
    return !const.isEmpty
  }

  private static let stringType = "string"
}

// MARK: - Format

public enum Format: FormatType, Decodable {
  case vcSdJwt(FormatType)

  // MARK: Lifecycle

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if let vcSdJwt = try container.decodeIfPresent(VcSdJwtFormat.self, forKey: .vcSdJwt) {
      self = .vcSdJwt(vcSdJwt)
    } else {
      throw RequestObjectError.invalidInputDescriptorFormat
    }
  }

  // MARK: Public

  public var label: String {
    switch self {
    case .vcSdJwt(let type): type.label
    }
  }

  public var vcAlgorithm: [String]? {
    switch self {
    case .vcSdJwt(let type): type.vcAlgorithm
    }
  }

  public var keyBindingAlgorithm: [String]? {
    switch self {
    case .vcSdJwt(let type): type.keyBindingAlgorithm
    }
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case vcSdJwt = "vc+sd-jwt"
  }

}

// MARK: - VcSdJwtFormat

/// https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-verifier-metadata
public struct VcSdJwtFormat: FormatType, Decodable, Equatable {
  public let vcAlgorithm: [String]?
  public let keyBindingAlgorithm: [String]?

  enum CodingKeys: String, CodingKey {
    case vcAlgorithm = "sd-jwt_alg_values"
    case keyBindingAlgorithm = "kb-jwt_alg_values"
  }

  public var label: String {
    "vc+sd-jwt"
  }
}

// MARK: - FormatType

public protocol FormatType: Decodable {
  var vcAlgorithm: [String]? { get }
  var keyBindingAlgorithm: [String]? { get }
  var label: String { get }
}
