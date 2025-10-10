import BITCore
import BITJWT
import BITSdJWT
import Foundation

// MARK: - RequestObjectError

public enum RequestObjectError: Error {
  case invalidPayload
  case invalidInputDescriptorFormat
}

// MARK: - RequestObject

/// A srtructure representing OpenID Authorization Request
/// https://openid.net/specs/openid-4-verifiable-presentations-1_0-20.html#name-authorization-request
public class RequestObject: Codable {

  // MARK: Lifecycle

  init(presentationDefinition: PresentationDefinition, nonce: String?, responseUri: URL, clientMetadata: ClientMetadata?, responseType: String, clientId: String, clientIdScheme: String?, responseMode: String) {
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
  public let responseUri: URL
  public let clientMetadata: ClientMetadata?
  public let responseType: String
  public let clientId: String
  public let clientIdScheme: String?
  public let responseMode: String

  public var firstInputDescriptor: InputDescriptor? {
    presentationDefinition.inputDescriptors.first
  }

  public func isEqual(to other: RequestObject) -> Bool {
    guard type(of: self) == type(of: other) else { return false }
    return responseMode == other.responseMode &&
      clientIdScheme == other.clientIdScheme &&
      clientId == other.clientId &&
      responseType == other.responseType &&
      responseUri == other.responseUri &&
      nonce == other.nonce &&
      clientMetadata == other.clientMetadata &&
      presentationDefinition == other.presentationDefinition
  }

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
    lhs.isEqual(to: rhs)
  }
}

public typealias Verifier = ClientMetadata

// MARK: - ClientMetadata

public struct ClientMetadata: Codable, Equatable {

  // MARK: Lifecycle

  public init(clientName: LocalizedDisplay<String>?, logoUri: LocalizedDisplay<URL>?) throws {
    self.clientName = clientName
    self.logoUri = logoUri
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicCodingKey.self)
    clientName = try LocalizedDisplay<String>(from: container, withBaseKey: "client_name")
    logoUri = try LocalizedDisplay<URL>(from: container, withBaseKey: "logo_uri")
  }

  // MARK: Public

  public let clientName: LocalizedDisplay<String>?
  public let logoUri: LocalizedDisplay<URL>?
}

// MARK: ClientMetadata.LocalizedDisplay

extension ClientMetadata {

  // MARK: Public

  /// Data model providing a Hash representation of the localized display
  /// where the  key of the hash is the language in two letters form (ISO-639)
  public struct LocalizedDisplay<T: Codable & Equatable>: Codable, Equatable {

    // MARK: Lifecycle

    init(values: [String: T]) {
      self.values = values
    }

    init?(from container: KeyedDecodingContainer<DynamicCodingKey>, withBaseKey baseKey: String) throws {
      for key in container.allKeys where key.stringValue.hasPrefix(baseKey) {
        let language = key.stringValue.components(separatedBy: ClientMetadata.separator).dropFirst().joined(separator: ClientMetadata.separator)
        if let value = try? container.decode(T.self, forKey: key) {
          values[String(language)] = value
        }
      }

      if values.isEmpty {
        return nil
      }
    }

    // MARK: Public

    /// Retrieves the preferred display from a set of localized displays, considering the given language codes in their order.
    ///
    /// - Returns: The best matching display based on the given language codes or a fallback if available. Returns `nil` if no display is found.
    public func getPreferredDisplay(considering languageCodes: [String] ) -> T? {
      languageCodes
        .lazy
        .compactMap { values[$0] }
        .first ?? values[""]
    }

    // MARK: Private

    private var values = [String: T]()
  }

  // MARK: Fileprivate

  fileprivate static let separator = "#"

}

// MARK: - PresentationDefinition

/// https://identity.foundation/presentation-exchange/spec/v2.1.0/#presentation-definition

public struct PresentationDefinition: Codable, Equatable {
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

public struct InputDescriptor: Codable, Equatable {

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
    guard path.contains(VcSdJwtPayload.vctPath) else { return true } // we ignore filters for paths that are not vct
    return filter?.isMatching(value) ?? true
  }

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

public enum Format: FormatType, Codable {
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

  public func encode(to encoder: any Encoder) throws {
    abort() // will be implemented if we actually need it
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
