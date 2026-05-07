import Foundation

public struct NonComplianceActivity: Codable, Equatable {
  let nonComplianceData: String?
  let createdAt: Date
  let issuer: String
}
