import Foundation

struct NFCScanResult: Codable, Equatable {
  let facePicture: Data
  let surname: String // Last name
  let givenName: String // First name
  let passportNumber: String
  let expirationDate: String
}
