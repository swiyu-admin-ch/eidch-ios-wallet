import BITCrypto
import Foundation

// MARK: - VcSdJwtOcaRendering

public struct VcSdJwtOcaRendering: Decodable, Equatable {
  public let uri: String
  public let uriIntegrity: IntegrityHash?

  enum CodingKeys: String, CodingKey {
    case uri
    case uriIntegrity = "uri#integrity"
  }

}

#if DEBUG
@testable import BITCore

extension VcSdJwtOcaRendering: Mockable {
  struct Mock {
    static let sampleWithInvalidScheme: VcSdJwtOcaRendering = Mocker.decode(fromFile: "oca-with-invalid-scheme", bundle: .module)
    static let sampleUri: VcSdJwtOcaRendering = Mocker.decode(fromFile: "uri-oca", bundle: .module)
    static let sampleUriWithoutIntegrity: VcSdJwtOcaRendering = Mocker.decode(fromFile: "uri-oca-without-integrity", bundle: .module)
    static let sampleData: VcSdJwtOcaRendering = Mocker.decode(fromFile: "data-oca", bundle: .module)
    static let sampleDataWithInvalidFormat: VcSdJwtOcaRendering = Mocker.decode(fromFile: "data-oca-with-invalid-format", bundle: .module)
  }
}
#endif
