import BITL10n
import BITTheming
import SwiftUI

// MARK: - RequestCasesListView

public struct RequestCasesListView: View {

  // MARK: Lifecycle

  public init(_ requestCases: [RequestCaseViewState]) {
    self.requestCases = requestCases
  }

  // MARK: Public

  public var body: some View {
    Section {
      ForEach(requestCases) { requestCase in
        VStack {
          switch requestCase {
          case .inQueue(let state):
            inQueueView(for: state)
          case .readyForOnlineSession(let state):
            readyForOnlineSessionView(for: state)
          case .expired(let state):
            expiredView(for: state)
          }
        }
        .padding(.x6)
        .background(ThemingAssets.Background.secondary.swiftUIColor)
        .cornerRadius(.CornerRadius.m)
      }
    }
  }

  // MARK: Private

  private enum AccessibilityPriority: Double {
    case x1 = 100
    case x2 = 80
    case x3 = 50
  }

  @Environment(\.sizeCategory) private var sizeCategory

  private let requestCases: [RequestCaseViewState]
}

// MARK: - Cells

extension RequestCasesListView {
  @ViewBuilder
  private func inQueueView(for state: InQueueStateViewModel) -> some View {
    HStack(alignment: .top, spacing: .x4) {
      image()
      content(
        title: L10n.tkGetEidNotificationEidProgressPrimary(state.fullName),
        content: L10n.tkGetEidNotificationEidProgressSecondary(state.formattedDate))

      Spacer()
    }
  }

  @ViewBuilder
  private func readyForOnlineSessionView(for state: ReadyForOnlineSessionStateViewModel) -> some View {
    HStack(alignment: .top, spacing: .x4) {
      image()

      VStack(alignment: .leading) {
        content(
          title: L10n.tkGetEidNotificationEidReadyPrimary(state.fullName),
          content: L10n.tkGetEidNotificationEidReadySecondary(state.formattedDate))

        Button(L10n.tkGetEidNotificationEidReadyGreenButton, action: state.primaryAction)
          .buttonStyle(.filledSecondary)
          .controlSize(.regular)
          .padding(.top, .x2)
          .dynamicTypeSize(...DynamicTypeSize.accessibility2)
          .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
      }

      Spacer()
    }
  }

  @ViewBuilder
  private func expiredView(for state: ExpiredStateViewModel) -> some View {
    HStack(alignment: .top, spacing: .x4) {
      image()

      content(title: L10n.tkGetEidNotificationEidExpiredPrimary(state.fullName), content: L10n.tkGetEidNotificationEidExpiredSecondary)

      Button(action: {
        Task {
          await state.primaryAction()
        }
      }, label: {
        Assets.close.swiftUIImage
          .accessibilityLabel(L10n.tkGetEidNotificationCloseButton)
          .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
      })
    }
    .frame(maxWidth: .infinity)
  }
}

// MARK: - Components

extension RequestCasesListView {

  @ViewBuilder
  private func content(title: String, content: String) -> some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(.custom.footnoteEmphasized)
        .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
        .accessibilityAddTraits(.isHeader)
        .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)

      Text(content)
        .font(.custom.footnote)
        .foregroundColor(ThemingAssets.Label.secondary.swiftUIColor)
        .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)
    }
  }

  @ViewBuilder
  private func image() -> some View {
    if !sizeCategory.isAccessibilityCategory {
      Assets.eidRequestCaseIcon.swiftUIImage
        .accessibilityHidden(true)
    }
  }
}
