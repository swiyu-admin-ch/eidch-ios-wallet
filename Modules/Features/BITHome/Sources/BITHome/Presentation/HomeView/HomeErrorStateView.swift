import BITL10n
import BITTheming
import SwiftUI

// MARK: - HomeErrorStateView

struct HomeErrorStateView: View {

  // MARK: Lifecycle

  init(_ error: Error, onRetry: @escaping () async -> Void) {
    self.error = error
    self.onRetry = onRetry
  }

  // MARK: Internal

  var body: some View {
    VStack {
      Spacer()
      emptyStateView
      Spacer()
    }
    .applyScrollViewIfNeeded(.vertical)
  }

  // MARK: Private

  private let error: Error
  private let onRetry: () async -> Void

  private var emptyStateView: some View {
    EmptyStateView(.error(error: error)) { Text(L10n.tkHomeHomescreenEmptyStateButton) } action: { await onRetry() }
      .padding(.horizontal, .x6)
  }
}
