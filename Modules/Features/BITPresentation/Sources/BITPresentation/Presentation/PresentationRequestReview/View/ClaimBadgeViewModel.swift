import Foundation

struct ClaimBadgeViewModel: Identifiable, Equatable, Hashable {
  var id = UUID()
  let name: String
  let isSensitive: Bool

  static func == (lhs: ClaimBadgeViewModel, rhs: ClaimBadgeViewModel) -> Bool {
    lhs.name == rhs.name &&
      lhs.isSensitive == rhs.isSensitive
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(name)
    hasher.combine(isSensitive)
  }
}
