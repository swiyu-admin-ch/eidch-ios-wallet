import Foundation
import Testing
@testable import BITCredentialShared

// MARK: - SequenceCredentialDisplayOrderTests

struct SequenceCredentialDisplayOrderTests {

  // MARK: Internal

  @Test
  func sortedByDisplayOrder_ordersByStatePriorityThenNewestFirst() {
    let orderables = [
      makeOrderable(.rejected, createdAt: 0),
      makeOrderable(.active, createdAt: 100),
      makeOrderable(.readyForActivation, createdAt: 0),
      makeOrderable(.active, createdAt: 300),
      makeOrderable(.inProgress, createdAt: 0),
      makeOrderable(.ghost, createdAt: 0),
    ]

    let sorted = orderables.sortedByDisplayOrder(using: \.self)

    #expect(sorted.map(\.displayOrder) == [.readyForActivation, .active, .active, .inProgress, .ghost, .rejected])
    // Within the two active items, the newest (300) comes before the older (100).
    #expect(sorted[1].createdAt == Date(timeIntervalSince1970: 300))
    #expect(sorted[2].createdAt == Date(timeIntervalSince1970: 100))
  }

  // MARK: Private

  private func makeOrderable(_ displayOrder: CredentialDisplayOrder, createdAt: TimeInterval) -> MockDisplayOrderable {
    MockDisplayOrderable(displayOrder: displayOrder, createdAt: Date(timeIntervalSince1970: createdAt))
  }
}

// MARK: - MockDisplayOrderable

private struct MockDisplayOrderable: CredentialDisplayOrderable {
  let displayOrder: CredentialDisplayOrder
  let createdAt: Date
}
