import BITCore
import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - RequestCasesListView

public struct RequestCasesListView: View {

  // MARK: Lifecycle

  public init(_ requestCases: [EIDRequestCase], action: @escaping (EIDRequestCase) -> Void) {
    self.requestCases = requestCases
    self.action = action
  }

  // MARK: Public

  public var body: some View {
    Section {
      ForEach(requestCases) { requestCase in
        VStack {
          switch requestCase.state?.state {
          case .inQueue:
            inQueueView(for: requestCase)
          case .readyForOnlineSession:
            readyForOnlineSessionView(for: requestCase)
          case .expired:
            expiredView(for: requestCase)
          default:
            EmptyView()
          }
        }
        .padding(.x6)
        .accessibilityElement(children: .combine)
        .background(ThemingAssets.Background.secondary.swiftUIColor)
        .cornerRadius(.CornerRadius.m)
      }
    }
  }

  // MARK: Private

  @Environment(\.sizeCategory) private var sizeCategory

  private let action: (EIDRequestCase) -> Void
  private let requestCases: [EIDRequestCase]
}

// MARK: - Cells

extension RequestCasesListView {
  @ViewBuilder
  private func inQueueView(for requestCase: EIDRequestCase) -> some View {
    HStack(alignment: .top, spacing: .x4) {
      image()
      content(
        title: L10n.tkGetEidNotificationEidProgressTitleIos(requestCase.fullName),
        content: L10n.tkGetEidNotificationEidProgressBodyIos(requestCase.state?.onlineSessionStartOpenAt?.longDateFormat ?? "-"))

      Spacer()
    }
  }

  @ViewBuilder
  private func readyForOnlineSessionView(for requestCase: EIDRequestCase) -> some View {
    HStack(alignment: .top, spacing: .x4) {
      image()

      VStack(alignment: .leading) {
        content(
          title: L10n.tkGetEidNotificationEidReadyTitleIos(requestCase.fullName),
          content: L10n.tkGetEidNotificationEidReadyBodyIos(requestCase.state?.onlineSessionStartTimeoutAt?.longDateFormat ?? "-"))

        Button(L10n.tkGetEidNotificationEidReadyGreenButton, action: {
          action(requestCase)
        })
        .buttonStyle(.filledSecondary)
        .controlSize(.regular)
        .padding(.top, .x2)
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
      }

      Spacer()
    }
  }

  @ViewBuilder
  private func expiredView(for requestCase: EIDRequestCase) -> some View {
    HStack(alignment: .top, spacing: .x4) {
      image()

      content(title: L10n.tkGetEidNotificationEidExpiredTitleIos(requestCase.fullName), content: L10n.tkGetEidNotificationEidExpiredBody)

      Button(action: {
        action(requestCase)
      }, label: {
        Assets.close.swiftUIImage
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

      Text(content)
        .font(.custom.footnote)
        .foregroundColor(ThemingAssets.Label.secondary.swiftUIColor)
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

#if DEBUG
#Preview {
  RequestCasesListView([.Mock.sampleExpired, .Mock.sampleAVReady, .Mock.sampleInQueue]) { _ in }
}
#endif
