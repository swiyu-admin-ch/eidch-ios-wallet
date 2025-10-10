struct AutoVerificationResponse: Codable, Equatable {

  // MARK: Internal

  let isNFCRequired: Bool
  let jwt: String

  enum CodingKeys: String, CodingKey {
    case jwt
    case isNFCRequired = "use_nfc"
    case isScanDocumentRequired = "scan_document"
    case isDocumentVideoRecordingRequired = "record_document_video"
  }

  // MARK: Private

  private let isScanDocumentRequired: Bool
  private let isDocumentVideoRecordingRequired: Bool
}
