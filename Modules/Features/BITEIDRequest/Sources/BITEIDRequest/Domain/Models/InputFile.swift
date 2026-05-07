import Foundation
import XMLCoder

struct InputFile: Codable, DynamicNodeEncoding {

  // MARK: Internal

  struct DocumentsData: Codable {
    var idDocuments: IdDocuments

    enum CodingKeys: String, CodingKey {
      case idDocuments = "IdDocuments"
    }

    struct IdDocuments: Codable {
      var document: [Document]

      struct Document: Codable {
        var documentType: String
        var secondaryRequired: Bool?
        var issuerCountry: String?
        var allowedNationality: [String]?
        var documentSubType: String?
      }
    }
  }

  struct Metadata: Codable {
    var deviceModelType: String
    var osVersion: String
  }

  var metadata: Metadata?

  static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
    .element
  }

  // MARK: Private

  private var documentsData: DocumentsData

}
