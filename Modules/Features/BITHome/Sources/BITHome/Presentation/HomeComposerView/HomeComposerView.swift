import BITCredential
import BITCredentialShared
import BITEIDRequest
import BITL10n
import BITSettings
import BITTheming
import Factory
import SwiftUI

// MARK: - HomeComposerView

struct HomeComposerView: View {

  // MARK: Lifecycle

  init(router: HomeRouterRoutes) {
    self.router = router

    _viewModel = StateObject(wrappedValue: Container.shared.homeViewModel(router))
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case scanButton
    case menuButton
  }

  var body: some View {
    content()
      .onAppear {
        UIAccessibility.post(notification: .screenChanged, argument: L10n.tkHomeHomescreenAlt)
        Task {
          await viewModel.onAppear()
        }

        Task {
          await viewModel.getEIDRequestCases()
        }
      }
      .accessibilityAction(named: L10n.tkGlobalScanPrimarybutton, {
        viewModel.openScanner()
      })
      .accessibilityAction(named: L10n.tkGlobalMoreoptionsAlt, {
        focus = .menu
      })

    NavigationLink(destination: PrivacyView(), isActive: $viewModel.isSecurityPresented) {
      EmptyView()
    }

    NavigationLink(destination: ImpressumView(), isActive: $viewModel.isImpressumPresented) {
      EmptyView()
    }

    NavigationLink(destination: LicencesListView(), isActive: $viewModel.isLicensesPresented) {
      EmptyView()
    }
  }

  // MARK: Private

  private enum FocusableElement: Hashable {
    case scan, menu, list, emptyState, error
  }

  @StateObject private var viewModel: HomeViewModel
  @Environment(\.sizeCategory) private var sizeCategory
  @AccessibilityFocusState
  private var focus: FocusableElement?

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

extension HomeComposerView {

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
          .accessibilitySortPriority(10)
      case .error:
        errorView()
      case .empty:
        emptyView()
          .listRowSeparator(.hidden)
      }
    }
    .refreshable {
      async let credentialStatus: Void = viewModel.send(event: .checkCredentialsStatus)
      async let requestCasesStatus: Void = viewModel.fetchEIDRequestStatus()

      _ = await (credentialStatus, requestCasesStatus)
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
        CredentialsEmptyStateView(betaIdAction: viewModel.openBetaId, eIDRequestAction: viewModel.openEIDRequest)
          .frame(maxWidth: .infinity)
          .padding(.horizontal, .x6)
        Spacer()
      }

      ScrollView {
        CredentialsEmptyStateView(betaIdAction: viewModel.openBetaId, eIDRequestAction: viewModel.openEIDRequest)
          .frame(maxWidth: .infinity)
          .padding(.horizontal, .x6)
      }
    }
  }

  @ViewBuilder
  private func errorView() -> some View {
    ViewThatFits(in: .vertical) {
      VStack {
        Spacer()
        EmptyStateView(.error(error: viewModel.stateError)) { Text("Refresh") } action: { await viewModel.send(event: .refresh) }
          .padding(.horizontal, .x6)
        Spacer()
      }

      ScrollView {
        EmptyStateView(.error(error: viewModel.stateError)) { Text("Refresh") } action: { await viewModel.send(event: .refresh) }
          .padding(.horizontal, .x6)
      }
    }
  }

  @ViewBuilder
  private func menuButton() -> some View {
    Menu {
      Section {
        Button { viewModel.openSecurity() } label: { Label(L10n.settingsSecurity, systemImage: "lock") }
      }

      Section {
        Button { viewModel.openSettings() } label: { Label(L10n.settingsLanguage, systemImage: "globe") }
        Button { viewModel.openHelp() } label: { Label(L10n.settingsHelp, systemImage: "questionmark.circle") }
        Button { viewModel.openContact() } label: { Label(L10n.settingsContact, systemImage: "envelope") }
        Button { viewModel.openFeedback() } label: { Label(L10n.tkMenuSettingWalletFeedback, systemImage: "text.bubble") }
      }

      Section {
        Button { viewModel.openImpressum() } label: { Label(L10n.settingsImpressum, systemImage: "info.circle") }
        Button { viewModel.openLicenses() } label: { Label(L10n.settingsLicences, systemImage: "doc") }
      }

      Section {
        Button(action: viewModel.openBetaId, label: {
          Label(L10n.tkGlobalGetbetaidPrimarybutton, systemImage: "person.text.rectangle")
            .accessibilityLabel(L10n.tkGlobalGetbetaidPrimarybutton)
        })

        if viewModel.isEIDRequestFeatureEnabled {
          Button(action: viewModel.openEIDRequest, label: {
            Label(L10n.tkGetEidHomePrimaryButton, systemImage: "person.text.rectangle")
              .accessibilityLabel(L10n.tkGetEidHomePrimaryButton)
          })
        }
      }
    } label: {
      HomeAssets.menuButton.swiftUIImage
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(height: 60)
        .accessibilityHidden(true)
    }
    .accessibilityLabel(L10n.tkGlobalMoreoptionsAlt)
    .accessibilityIdentifier(AccessibilityIdentifier.menuButton.rawValue)
    .accessibilitySortPriority(50)
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
      .accessibilitySortPriority(100)
      .accessibilityFocused($focus, equals: .scan)
    } else {
      Button(action: viewModel.openScanner, label: {
        Label(title: { Text(L10n.tkGlobalScanPrimarybutton) }, icon: { Image(systemName: "qrcode") })
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      })
      .buttonStyle(.filledPrimary)
      .accessibilityLabel(L10n.tkGlobalScanPrimarybuttonAlt)
      .accessibilityIdentifier(AccessibilityIdentifier.scanButton.rawValue)
      .accessibilitySortPriority(100)
      .frame(height: 60)
      .accessibilityFocused($focus, equals: .scan)
    }
  }

  @ViewBuilder
  private func credentialsList() -> some View {
    ForEach(viewModel.credentials) { credential in
      Button(action: { viewModel.openDetail(for: credential) }, label: {
        CredentialCell(credential)
      })
    }
  }
}

// MARK: - Portrait

extension HomeComposerView {
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

extension HomeComposerView {
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
  HomeComposerView(router: HomeRouter())
}
#endif
