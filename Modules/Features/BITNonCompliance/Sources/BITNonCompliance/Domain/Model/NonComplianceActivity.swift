import Foundation

public struct NonComplianceActivity: Codable, Equatable, Sendable {
  let nonComplianceData: String?
  let createdAt: Date
  let issuer: String
}
