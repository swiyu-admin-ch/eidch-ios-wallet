import BITL10n
import BITTheming
import NavigatorUI
import SwiftUI

// MARK: - NonComplianceInfoView

struct NonComplianceInfoView: View {

  // MARK: Lifecycle

  init(category: NonComplianceCategory, activityId: UUID) {
    self.category = category
    self.activityId = activityId
  }

  // MARK: Internal

  var body: some View {
    ZStack(alignment: .top) {
      ThemingAssets.Background.secondary.swiftUIColor
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
      content
    }
    .navigationBar(.secondaryScroll, scrollEdgeAppearance: .secondary)
    .navigationTitle(category.title)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      CloseButtonToolbar(action: {
        navigator.dismiss()
      })
    }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  private let category: NonComplianceCategory
  private let activityId: UUID

  private var content: some View {
    List {
      Section {
        infoView
        moreInfoLink
      } footer: {
        Text(L10n.tkNonComplianceListFooter)
      }
      .listRowSeparator(.hidden)
    }
    .landscapeMaxWidth()
    .scrollContentBackground(.hidden)
    .safeAreaInset(edge: .bottom) {
      button
    }
  }

  private var infoView: some View {
    VStack(spacing: 0) {
      VStack(spacing: .x1) {
        Assets.lightbulb.swiftUIImage
          .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
          .accessibilityHidden(true)
        Text(L10n.tkNonComplianceReportInfoTitle)
          .font(.custom.bodyEmphasized)
          .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
          .accessibilityAddTraits(.isHeader)
        Text(L10n.tkNonComplianceReportInfoBody)
          .multilineTextAlignment(.center)
          .font(.custom.subheadline)
          .foregroundColor(ThemingAssets.Label.secondary.swiftUIColor)
      }
      .padding(.horizontal, .x4)
      .padding(.vertical, .x6)
      Divider()
    }
    .listRowInsets(EdgeInsets())
  }

  @ViewBuilder
  private var moreInfoLink: some View {
    if let url = URL(string: L10n.tkNonComplianceReportInfoMoreInformationLinkValue) {
      HStack(spacing: 0) {
        CustomLink(to: url, label: L10n.tkNonComplianceReportInfoMoreInformationLinkText)
        Spacer()
      }
    }
  }

  private var button: some View {
    ButtonSheet(colorConfig: .secondary) {
      Button {
        navigator.navigate(to: NonComplianceInternalDestinations.form(category: category, activityId: activityId))
      } label: {
        Text(L10n.tkGlobalContinue)
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.primary)
      .controlSize(.large)
    }
  }
}

extension NonComplianceCategory {
  fileprivate var title: String {
    switch self {
    case .excessiveDataRequest: L10n.tkNonComplianceReportExcessiveDataTitle
    }
  }
}
