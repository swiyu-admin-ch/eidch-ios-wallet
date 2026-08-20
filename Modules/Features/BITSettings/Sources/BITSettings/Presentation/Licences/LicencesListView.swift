import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - LicencesListView

public struct LicencesListView: View {

  // MARK: Lifecycle

  public init() {
    _viewModel = State(initialValue: Container.shared.licencesViewModel())
  }

  // MARK: Public

  public var body: some View {
    SettingsPage(title: L10n.tkSettingsLicencesTitle) {
      switch viewModel.state {
      case .loading:
        ProgressView()
      case .results:
        resultsList()
      case .error:
        EmptyStateView(.error(error: viewModel.stateError)) {}
      case .empty:
        EmptyStateView(.custom(title: nil, message: L10n.tkSettingsLicencesEmptyState, image: nil, imageColor: nil)) {}
      }
    }
    .onFirstAppear {
      Task { await viewModel.send(event: .fetch) }
    }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator
  @State private var viewModel: LicencesListViewModel

  @ViewBuilder
  private func resultsList() -> some View {
    SettingsSection {
      VStack(alignment: .leading, spacing: .x6) {
        Text(L10n.tkSettingsLicencesBody)
          .font(.custom.body)
          .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)

        if let url = URL(string: L10n.tkSettingsLicencesLinkValue) {
          CustomLink(to: url, label: L10n.tkSettingsLicencesLinkText)
        }
      }
      .padding(.vertical, .x4)
      .padding(.horizontal, .x6)
      .frame(maxWidth: .infinity)
    }

    SettingsSection {
      ForEach(Array(zip(viewModel.packages.indices, viewModel.packages)), id: \.0) { index, package in
        SettingsItem(
          title: package.name,
          detail: package.version ?? L10n.tkSettingsLicencesNoVersion,
          type: .navigation { navigator.navigate(to: SettingsDestinations.licenseDetail(package)) },
          hasDivider: index < viewModel.packages.count - 1)
      }
    }
  }
}

#Preview {
  LicencesListView()
}
