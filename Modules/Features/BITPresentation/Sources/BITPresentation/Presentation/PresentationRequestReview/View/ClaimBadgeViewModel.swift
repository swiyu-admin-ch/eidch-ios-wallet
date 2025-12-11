import Foundation

struct ClaimBadgeViewModel: Identifiable, Equatable {
  var id = UUID()
  let name: String
  let isSensitive: Bool
}
