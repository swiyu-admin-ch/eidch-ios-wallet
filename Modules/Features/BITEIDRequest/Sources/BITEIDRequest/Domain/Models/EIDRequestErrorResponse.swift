struct EIDRequestErrorResponse: Codable {

  struct Error: Codable {

    // MARK: Internal

    enum Code: String, Codable {
      case invalidClientAttestation = "InvalidClientAttestation"
      case invalidKeyAttestation = "InvalidKeyAttestation"
      case insufficientKeyStorageResistance = "InsufficientKeyStorageResistance"
      case invalidState = "AntragInWrongStateException"
      case notFound = "NoResourceFoundException"
      case legalRepresentantNotRequired = "LegalRepresentantNotRequiredException"
    }

    let code: Code?

    // MARK: Private

    private let id: String
    private let status: Int
    private let message: String
    private let transferId: String?
    private let correlationId: String?
    private let translations: [String: String]?
    private let messageKey: String?
  }

  let errors: [Error]
}
