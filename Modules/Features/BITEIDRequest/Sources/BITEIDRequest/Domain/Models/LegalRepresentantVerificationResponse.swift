import Foundation

struct LegalRepresentantVerificationResponse: Decodable, Equatable {
  let requestUrl: URL
  let verifierLink: URL

  enum CodingKeys: String, CodingKey {
    case requestUrl = "legalRepresentantVerificationRequestUrl"
    case verifierLink = "legalRepresentantVerifierLink"
  }
}
