import BITCore
import BITCrypto
import BITOca
import Foundation

// MARK: - TypeMetadata

/// TypeMetadata
/// - Documentation: [SD-JWT-based Verifiable Credentials - Draft 06](https://www.ietf.org/archive/id/draft-ietf-oauth-sd-jwt-vc-06.html#name-sd-jwt-vc-type-metadata)
public struct TypeMetadata: Decodable {

  // MARK: Public

  public let vct: String
  public let displays: [Display]?

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case vct
    case name
    case description
    case displays = "display"
    case schemaUrl = "schema_uri"
    case schemaIntegrity = "schema_uri#integrity"
  }

  let name: String?
  let description: String?

  let schemaUrl: URL?
  let schemaIntegrity: IntegrityHash?

}

// MARK: Equatable

extension TypeMetadata: Equatable {
}

// MARK: TypeMetadata.Display

extension TypeMetadata {

  public struct Display: Decodable, Equatable {
    public let lang: String
    public let name: String
    public let rendering: Rendering?

    let description: String?

  }

}

// MARK: - TypeMetadata.Display.Rendering

extension TypeMetadata.Display {

  public struct Rendering: Decodable, Equatable {

    // MARK: Public

    public let oca: VcSdJwtOcaRendering?

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
      case oca
    }
  }

}

#if DEBUG
@testable import BITCore

extension TypeMetadata: Mockable {

  struct Mock {
    static let sample: TypeMetadata = Mocker.decode(fromFile: "typemetadata-url-oca", bundle: .module)
    static let sampleWithoutSchemaUrl: TypeMetadata = Mocker.decode(fromFile: "typemetadata-without-schema-url", bundle: .module)
    static let sampleWithoutUrlIntegrity: TypeMetadata = Mocker.decode(fromFile: "typemetadata-without-url-integrity", bundle: .module)
    static let sampleStandard: TypeMetadata = Mocker.decode(fromFile: "typemetadata-standard", bundle: .module) // Based on the Appendix proposed here: https://www.ietf.org/archive/id/draft-ietf-oauth-sd-jwt-vc-05.html#ExampleTypeMetadata

    static let sampleStandardData: Data = Mocker.getData(fromFile: "typemetadata-standard", bundle: .module) ?? Data()
    static let sampleWithoutSchemaUrlData: Data = Mocker.getData(fromFile: "typemetadata-without-schema-url", bundle: .module) ?? Data()
  }

}
#endif
