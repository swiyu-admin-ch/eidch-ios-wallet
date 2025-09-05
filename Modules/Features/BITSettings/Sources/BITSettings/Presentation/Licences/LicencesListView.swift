import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - LicencesListView

public struct LicencesListView: View {

  // MARK: Lifecycle

  public init(path: Binding<NavigationPath>) {
    _path = path
    _viewModel = StateObject(wrappedValue: Container.shared.licencesViewModel())
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
    .navigationDestination(for: PackageDependency.self) { package in
      LicenceDetailView(package: package)
    }
  }

  // MARK: Private

  @StateObject private var viewModel: LicencesListViewModel
  @Binding private var path: NavigationPath

  @ViewBuilder
  private func resultsList() -> some View {
    SettingsSection {
      VStack(alignment: .leading, spacing: .x6) {
        Text(L10n.tkSettingsLicencesBody)
          .font(.custom.body)
          .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)

        if let url = URL(string: L10n.tkSettingsLicencesLinkValue) {
          Link(destination: url) {
            LinkText(L10n.tkSettingsLicencesLinkText)
              .font(.custom.footnote)
          }
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
          type: .navigation { path.append(package) },
          hasDivider: index < viewModel.packages.count - 1)
      }
    }
  }
}

#Preview {
  LicencesListView(path: .constant(NavigationPath()))
}
