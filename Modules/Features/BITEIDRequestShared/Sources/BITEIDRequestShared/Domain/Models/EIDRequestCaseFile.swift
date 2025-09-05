import BITAVWrapper
import BITEntities
import Foundation


enum EIDRequestCaseFileError: Error {
  case cannotParseEntity
}


public struct EIDRequestCaseFile: Decodable, Identifiable, Equatable {

  // MARK: Lifecycle

  public init(id: UUID = UUID(), fileName: String, mime: AVBeamFileType, data: Data, category: Category, createdAt: Date = Date()) {
    self.id = id
    self.fileName = fileName
    self.mime = mime
    self.data = data
    self.category = category
    self.createdAt = createdAt
  }

  public init(_ entity: EIDRequestCaseFileEntity) throws {
    guard
      let category = Category(rawValue: entity.category),
      let mime = AVBeamFileType(entity.mime)
    else
    {
      throw EIDRequestCaseFileError.cannotParseEntity
    }

    self.init(
      id: entity.id,
      fileName: entity.fileName,
      mime: mime,
      data: entity.data,
      category: category,
      createdAt: entity.createdAt)
  }

  // MARK: Public

  public enum Category: String, Decodable {
    case documentScan
    case documentRecording
    case faceRecording
    case nfcScan
  }

  public let id: UUID

  public let fileName: String
  public let mime: AVBeamFileType
  public let data: Data
  public let category: Category
  public let createdAt: Date

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case id
    case fileName
    case mime
    case category
    case data
    case createdAt
  }

  // MARK: Private

  private static let mrzSeparator = ";"

}

extension EIDRequestCaseFileEntity {

  public convenience init(_ file: EIDRequestCaseFile) {
    self.init()

    id = file.id
    fileName = file.fileName
    mime = file.mime.mimeType
    data = file.data
    category = file.category.rawValue
    createdAt = file.createdAt
  }

}

// MARK: - AVBeamFileType + Decodable

extension AVBeamFileType: Decodable {}
