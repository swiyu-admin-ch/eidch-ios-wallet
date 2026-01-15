import BITCredential
import BITCredentialShared
import BITEIDRequest
import BITL10n
import BITSettings
import BITTheming
import Factory
import SwiftUI

// MARK: - HomeView

struct HomeView: View {

  // MARK: Lifecycle

  init(router: HomeRouterRoutes) {
    self.router = router

    _viewModel = StateObject(wrappedValue: Container.shared.homeViewModel(router))
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "homeContent"
    case scanButton
    case menuButton
    case credential
  }

  var body: some View {
    content()
      .onAppear {
        UIAccessibility.post(notification: .screenChanged, argument: L10n.tkHomeHomescreenAlt)
        focus = .scan

        Task {
          await viewModel.onAppear()
        }
      }
      .accessibilityAction(named: L10n.tkGlobalScanPrimarybutton, {
        viewModel.openScanner()
      })
      .accessibilityAction(named: L10n.tkGlobalMoreoptionsAlt, {
        focus = .menu
      })
      .onColorSchemeChange { scheme in
        viewModel.updateCredentialViewModels(with: scheme.rawValue)
      }
      .popup(isPresented: $viewModel.isCredentialSavedPopupPresented) {
        savedCredentialPopup()
      } customize: {
        $0.type(.floater(verticalPadding: orientation.isPortrait ? 130 : 0))
          .closeOnTap(true)
          .autohideIn(5)
          .appearFrom(.bottomSlide)
      }
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  // MARK: Private

  private enum FocusableElement: Hashable {
    case scan, menu, list, emptyState, error
  }

  @StateObject private var viewModel: HomeViewModel
  @Environment(\.sizeCategory) private var sizeCategory
  @AccessibilityFocusState private var focus: FocusableElement?

  @Injected(\.isEIDRequestFeatureEnabled) private var isEIDRequestFeatureEnabled: Bool

  private let router: HomeRouterRoutes

  @Orientation private var orientation

  @ViewBuilder
  private func content() -> some View {
    if orientation.isPortrait {
      portraitLayout()
    } else {
      landscapeLayout()
    }
  }

}

// MARK: - Components

extension HomeView {

  @ViewBuilder
  private func mainContent() -> some View {
    List {
      RequestCasesListView(viewModel.requestCases)
        .listRowSeparator(.hidden)
      switch viewModel.state {
      case .results:
        credentialsList()
          .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor, ThemingAssets.Label.primary.swiftUIColor)
          .accessibilityFocused($focus, equals: .list)
          .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
      case .error(let error):
        errorView(error)
      case .empty:
        emptyView()
          .listRowSeparator(.hidden)
      }
    }
    .refreshable {
      await viewModel.refresh()
    }
    .listRowSpacing(-10)
    .listStyle(.plain)
    .safeAreaInset(edge: .bottom) {
      if !orientation.isLandscape {
        portraitFooter()
      }
    }
  }

  @ViewBuilder
  private func emptyView() -> some View {
    ViewThatFits(in: .vertical) {
      VStack {
        Spacer()
        credentialEmptyStateView()
          .frame(maxWidth: .infinity)
          .padding(.horizontal, .x6)
        Spacer()
      }

      ScrollView {
        credentialEmptyStateView()
          .frame(maxWidth: .infinity)
          .padding(.horizontal, .x6)
      }
    }
  }

  @ViewBuilder
  private func errorView(_ error: Error) -> some View {
    ViewThatFits(in: .vertical) {
      VStack {
        Spacer()
        emptyStateView(error)
        Spacer()
      }
      .applyScrollViewIfNeeded()
    }
  }

  @ViewBuilder
  private func menuButton() -> some View {
    Menu {
      Section {
        Button(action: viewModel.openBetaId, label: {
          Label(title: { Text(L10n.tkMenuHomeListAdd) }) { HomeAssets.menuID.swiftUIImage }
        })

        if viewModel.isEIDRequestFeatureEnabled {
          Button(action: viewModel.openEIDRequest, label: {
            Label(title: { Text(L10n.tkMenuHomeListOrderEid) }) { HomeAssets.menuID.swiftUIImage }
          })
        }
      }
      Section {
        Button(action: viewModel.openSettings, label: {
          Label(title: { Text(L10n.tkMenuHomeListSettings) }) { HomeAssets.menuSettings.swiftUIImage }
        })
        Button(action: viewModel.openHelp, label: {
          Label(title: { Text(L10n.tkMenuHomeListHelp) }) { HomeAssets.menuHelp.swiftUIImage }
        })
        .accessibilityAddTraits(.isLink)
      }
    } label: {
      HomeAssets.menuButton.swiftUIImage
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(height: 60)
        .accessibilityHidden(true)
    }
    .menuOrder(.fixed)
    .accessibilityLabel(L10n.tkGlobalMoreoptionsAlt)
    .accessibilityIdentifier(AccessibilityIdentifier.menuButton.rawValue)
    .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)
    .accessibilityFocused($focus, equals: .menu)
    .accessibilityAddTraits(.isButton)
  }

  @ViewBuilder
  private func scannerButton() -> some View {
    if sizeCategory.isAccessibilityCategory || orientation.isLandscape {
      Button(action: viewModel.openScanner) {
        HomeAssets.scannerButton.swiftUIImage
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(height: 60)
      }
      .accessibilityLabel(L10n.tkGlobalScanPrimarybuttonAlt)
      .accessibilityIdentifier(AccessibilityIdentifier.scanButton.rawValue)
      .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)
      .accessibilityFocused($focus, equals: .scan)
    } else {
      Button(action: viewModel.openScanner, label: {
        Label(title: { Text(L10n.tkGlobalScanPrimarybutton) }, icon: { Image(systemName: "qrcode") })
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      })
      .buttonStyle(.primary)
      .accessibilityLabel(L10n.tkGlobalScanPrimarybuttonAlt)
      .accessibilityIdentifier(AccessibilityIdentifier.scanButton.rawValue)
      .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)
      .frame(height: 60)
      .accessibilityFocused($focus, equals: .scan)
    }
  }

  @ViewBuilder
  private func credentialsList() -> some View {
    ForEach(viewModel.credentials, id: \.id) { credential in
      Button(action: { viewModel.openCredential(credential) }, label: {
        AnyView(credential.view())
      })
      .accessibilityIdentifier(AccessibilityIdentifier.credential.rawValue)
    }
  }

  @ViewBuilder
  private func credentialEmptyStateView() -> some View {
    VStack(alignment: .center, spacing: .x1) {
      if !sizeCategory.isAccessibilityCategory {
        HomeAssets.emptyWalletIcon.swiftUIImage
          .padding(.bottom, .x6)
          .accessibilityHidden(true)
      }

      Text(L10n.tkGetBetaIdFirstUseTitle)
        .multilineTextAlignment(.center)
        .font(.custom.title3)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .accessibilityLabel(L10n.tkGetBetaIdFirstUseTitle)
        .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)
        .accessibilityAddTraits(.isHeader)

      Text(L10n.tkGetBetaIdFirstUseBody)
        .multilineTextAlignment(.center)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
        .accessibilityLabel(L10n.tkGetBetaIdFirstUseBody)
        .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)

      if isEIDRequestFeatureEnabled {
        Button(action: viewModel.openEIDRequest, label: {
          Label(L10n.tkMenuHomeListOrderEid, systemImage: "arrow.forward")
        })
        .buttonStyle(.tertiary)
        .controlSize(.large)
        .accessibilityLabel(L10n.tkMenuHomeListOrderEid)
        .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
        .padding(.top, .x6)
      }

      Button(action: viewModel.openBetaId, label: {
        Label(title: { Text(L10n.tkGlobalGetbetaidPrimarybutton) }, icon: { Image(systemName: "arrow.forward") })
      })
      .buttonStyle(.tertiary)
      .controlSize(.large)
      .accessibilityLabel(L10n.tkGlobalGetbetaidPrimarybutton)
      .accessibilitySortPriority(AccessibilityPriority.x4.rawValue)
      .padding(.top, .x4)
    }
  }

  @ViewBuilder
  private func emptyStateView(_ error: Error) -> some View {
    EmptyStateView(.error(error: error)) { Text(L10n.tkHomeHomescreenEmptyStateButton) } action: { await viewModel.refresh() }
      .padding(.horizontal, .x6)
  }

  @ViewBuilder
  private func savedCredentialPopup() -> some View {
    LabelBadge(text: L10n.tkHomeSaveDeferredCredentialPopup, backgroundColor: ThemingAssets.Brand.Bright.firGreen.swiftUIColor, image: "checkmark.circle")
  }
}

// MARK: - Portrait

extension HomeView {
  @ViewBuilder
  private func portraitLayout() -> some View {
    mainContent()
  }

  @ViewBuilder
  private func portraitFooter() -> some View {
    VStack {
      HStack {
        menuButton()
        scannerButton()
      }
      .padding(.horizontal, .x3)
      .padding(.vertical, 10)
    }
    .background(.ultraThinMaterial)
    .clipShape(.capsule)
    .padding(.horizontal, .x6)
    .padding(.vertical, .x4)
  }
}

// MARK: - Landscape

extension HomeView {
  @ViewBuilder
  private func landscapeLayout() -> some View {
    ViewThatFits(in: .vertical) {
      landscapeContentLayout()
      landscapeScrollableContentLayout()
    }
  }

  @ViewBuilder
  private func landscapeContentLayout() -> some View {
    HStack {
      landscapeFooter()
      Spacer()
      mainContent()
    }
  }

  @ViewBuilder
  private func landscapeScrollableContentLayout() -> some View {
    HStack {
      landscapeFooter()

      mainContent()
        .padding(.x4)
    }
    .padding(.vertical, .x4)
  }

  @ViewBuilder
  private func landscapeFooter() -> some View {
    VStack {
      Spacer()
      menuButton()
      scannerButton()
      Spacer()
    }
    .padding(.x4)
    .ignoresSafeArea(edges: .bottom)
  }
}

#if DEBUG
#Preview {
  HomeView(router: HomeRouter())
}
#endif
