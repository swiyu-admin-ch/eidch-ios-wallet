import BITCore
import BITCrypto
import BITOca
import Foundation

// MARK: - TypeMetadata

/// TypeMetadata
/// - Documentation: [SD-JWT-based Verifiable Credentials - Draft 06](https://www.ietf.org/archive/id/draft-ietf-oauth-sd-jwt-vc-06.html#name-sd-jwt-vc-type-metadata)
public struct TypeMetadata: Decodable {

  // MARK: Public

  public let displays: [Display]?

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case vct
    case name
    case description
    case extends
    case displays = "display"
    case claims
    case schema
    case schemaUrl = "schema_uri"
    case schemaIntegrity = "schema_uri#integrity"
  }

  let vct: String?
  let name: String?
  let description: String?
  let extends: URL?

  let claims: [Claim]?
  let schemaUrl: URL?
  let schemaIntegrity: IntegrityHash?

  /// Not supported by swiss-profile
  let schema: String?

}

// MARK: Equatable

extension TypeMetadata: Equatable {
  public static func == (lhs: TypeMetadata, rhs: TypeMetadata) -> Bool {
    lhs.vct == rhs.vct
      && lhs.name == rhs.name
      && lhs.description == rhs.description
      && lhs.extends == rhs.extends
      && lhs.displays == rhs.displays
  }
}

// MARK: TypeMetadata.Display

extension TypeMetadata {

  public struct Display: Decodable, Equatable {
    public let lang: String
    public let name: String
    public let rendering: Rendering?

    let description: String?

    public static func == (lhs: TypeMetadata.Display, rhs: TypeMetadata.Display) -> Bool {
      lhs.lang == rhs.lang
        && lhs.name == rhs.name
        && lhs.description == rhs.description
        && lhs.rendering == rhs.rendering
    }
  }

}

// MARK: - TypeMetadata.Display.Rendering

extension TypeMetadata.Display {

  public struct Rendering: Decodable, Equatable {

    // MARK: Public

    public let oca: VcSdJwtOcaRendering?

    public static func == (lhs: TypeMetadata.Display.Rendering, rhs: TypeMetadata.Display.Rendering) -> Bool {
      lhs.simple == rhs.simple
        && lhs.svgTemplates == rhs.svgTemplates
        && lhs.oca == rhs.oca
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
      case simple
      case svgTemplates = "svg_templates"
      case oca
    }

    let simple: SimpleRendering?
    let svgTemplates: [SVGTemplate]?
  }

}

extension TypeMetadata.Display.Rendering {

  struct SimpleRendering: Decodable, Equatable {
    let logo: Logo?
    let backgroundColor: String?
    let textColor: String?

    enum CodingKeys: String, CodingKey {
      case logo
      case backgroundColor = "background_color"
      case textColor = "text_color"
    }

    static func == (lhs: TypeMetadata.Display.Rendering.SimpleRendering, rhs: TypeMetadata.Display.Rendering.SimpleRendering) -> Bool {
      lhs.logo == rhs.logo
        && lhs.backgroundColor == rhs.backgroundColor
        && lhs.textColor == rhs.textColor
    }
  }

  struct Logo: Decodable, Equatable {
    let uri: String
    let uriIntegrity: IntegrityHash?
    let altText: String?

    enum CodingKeys: String, CodingKey {
      case uri
      case uriIntegrity = "uri#integrity"
      case altText = "alt_text"
    }

    static func == (lhs: TypeMetadata.Display.Rendering.Logo, rhs: TypeMetadata.Display.Rendering.Logo) -> Bool {
      lhs.uri == rhs.uri
        && lhs.uriIntegrity == rhs.uriIntegrity
        && lhs.altText == rhs.altText
    }
  }

}

extension TypeMetadata.Display.Rendering {

  struct SVGTemplate: Decodable, Equatable {
    let uri: String
    let uriIntegrity: IntegrityHash?
    let properties: SVGProperties?

    enum CodingKeys: String, CodingKey {
      case uri
      case uriIntegrity = "uri#integrity"
      case properties
    }

    static func == (lhs: TypeMetadata.Display.Rendering.SVGTemplate, rhs: TypeMetadata.Display.Rendering.SVGTemplate) -> Bool {
      lhs.uri == rhs.uri
        && lhs.uriIntegrity == rhs.uriIntegrity
        && lhs.properties == rhs.properties
    }
  }

  struct SVGProperties: Decodable, Equatable {
    let orientation: String?
    let colorScheme: String?
    let contrast: String?

    enum CodingKeys: String, CodingKey {
      case orientation
      case colorScheme = "color_scheme"
      case contrast
    }

    static func == (lhs: TypeMetadata.Display.Rendering.SVGProperties, rhs: TypeMetadata.Display.Rendering.SVGProperties) -> Bool {
      lhs.orientation == rhs.orientation
        && lhs.colorScheme == rhs.colorScheme
        && lhs.contrast == rhs.contrast
    }
  }

}

// MARK: - TypeMetadata.Claim

extension TypeMetadata {
  struct Claim: Decodable {
    let path: [PathElement]
    let display: [ClaimDisplay]?
    var sd: SelectiveDisclosure? = .allowed
    let svgId: String?

    enum CodingKeys: String, CodingKey {
      case path
      case display
      case sd
      case svgId = "svg_id"
    }
  }
}

extension TypeMetadata.Claim {

  enum PathElement: Decodable {
    case string(String)
    case int(Int)
    case null

    // MARK: Lifecycle

    init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      if let stringValue = try? container.decode(String.self) {
        self = .string(stringValue)
      } else if let intValue = try? container.decode(Int.self), intValue >= 0 {
        self = .int(intValue)
      } else if container.decodeNil() {
        self = .null
      } else {
        throw DecodingError.dataCorruptedError(
          in: container,
          debugDescription: "Invalid claim path element. Must be string, non-negative integer, or null.")
      }
    }
  }

  struct ClaimDisplay: Decodable {
    let lang: String
    let label: String
    let description: String?
  }

  enum SelectiveDisclosure: String, Decodable {
    case always
    case allowed
    case never
  }
}

#if DEBUG
@testable import BITTestingCore

extension TypeMetadata: Mockable {

  struct Mock {
    static let sampleUrlOca: TypeMetadata = Mocker.decode(fromFile: "typemetadata-url-oca", bundle: .module)
    static let sampleDataOca: TypeMetadata = Mocker.decode(fromFile: "typemetadata-data-oca", bundle: .module)

    static let sampleMultipleDisplays: TypeMetadata = Mocker.decode(fromFile: "typemetadata-multiple-displays", bundle: .module)
    static let sampleWithoutDisplays: TypeMetadata = Mocker.decode(fromFile: "typemetadata-without-displays", bundle: .module)
    static let sampleWithoutOca: TypeMetadata = Mocker.decode(fromFile: "typemetadata-without-oca", bundle: .module)

    static let sampleWithoutSchemaUrl: TypeMetadata = Mocker.decode(fromFile: "typemetadata-without-schema-url", bundle: .module)
    static let sampleWithoutUrlIntegrity: TypeMetadata = Mocker.decode(fromFile: "typemetadata-without-url-integrity", bundle: .module)
    static let sampleStandard: TypeMetadata = Mocker.decode(fromFile: "typemetadata-standard", bundle: .module) // Based on the Appendix proposed here: https://www.ietf.org/archive/id/draft-ietf-oauth-sd-jwt-vc-05.html#ExampleTypeMetadata

    static let sampleStandardData: Data = Mocker.getData(fromFile: "typemetadata-standard", bundle: .module) ?? Data()
    static let sampleWithoutSchemaUrlData: Data = Mocker.getData(fromFile: "typemetadata-without-schema-url", bundle: .module) ?? Data()
  }

}
#endif
