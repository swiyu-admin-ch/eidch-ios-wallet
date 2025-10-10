struct EIDRequestPayload: Codable, Equatable {

  // MARK: Lifecycle

  init(mrz: [String], hasLegalRepresentant: Bool = false, email: String? = nil) {
    self.mrz = mrz
    self.hasLegalRepresentant = hasLegalRepresentant
    self.email = email
  }

  // MARK: Internal

  let mrz: [String]
  let hasLegalRepresentant: Bool

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case mrz
    case hasLegalRepresentant = "legalRepresentant"
    case email
  }

  private let email: String?
}
