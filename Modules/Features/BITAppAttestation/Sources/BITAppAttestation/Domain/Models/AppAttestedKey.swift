import Foundation

struct AppAttestedKey: Decodable {
  let clientData: Data
  let identifier: String
}
