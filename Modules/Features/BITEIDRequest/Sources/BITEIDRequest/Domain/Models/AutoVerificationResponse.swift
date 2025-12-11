struct AutoVerificationResponse: Codable, Hashable {

  // MARK: Internal

  let jwt: String
  let isNFCRequired: Bool
  let isScanDocumentRequired: Bool
  let isDocumentVideoRecordingRequired: Bool

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case jwt
    case isNFCRequired = "use_nfc"
    case isScanDocumentRequired = "scan_document"
    case isDocumentVideoRecordingRequired = "record_document_video"
  }

}
