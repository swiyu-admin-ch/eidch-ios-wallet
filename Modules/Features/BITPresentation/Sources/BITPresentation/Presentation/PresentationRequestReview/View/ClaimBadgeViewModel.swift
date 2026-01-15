import Foundation

struct ClaimBadgeViewModel: Identifiable, Equatable {
  var id = UUID()
  let name: String
  let isSensitive: Bool

  static func == (lhs: ClaimBadgeViewModel, rhs: ClaimBadgeViewModel) -> Bool {
    lhs.name == rhs.name &&
      lhs.isSensitive == rhs.isSensitive
  }
}
