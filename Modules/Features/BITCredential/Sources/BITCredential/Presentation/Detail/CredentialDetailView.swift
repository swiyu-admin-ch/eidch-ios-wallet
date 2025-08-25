import BITCredentialShared
import BITL10n
import BITTheming
import Factory
import Refresher
import SwiftUI

// MARK: - CredentialDetailView

struct CredentialDetailView: View {

  // MARK: Lifecycle

  init(credential: Credential, router: CredentialDetailInternalRoutes) {
    _viewModel = StateObject(wrappedValue: Container.shared.credentialDetailViewModel((credential, router)))
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "credentialDetailContent"
    case closeButton
    case menuButton
    case deleteButton
    case wrongDataButton
    case card
  }

  var body: some View {
    content()
      .alert(isPresented: $viewModel.isDeleteCredentialAlertPresented) {
        Alert(
          title: Text(L10n.tkDisplaydeleteCredentialdeleteTitle),
          message: Text(L10n.tkDisplaydeleteCredentialdeleteBody),
          primaryButton: .destructive(Text(L10n.tkGlobalDelete), action: {
            Task {
              await viewModel.deleteCredential()
            }
          }),
          secondaryButton: .cancel(Text(L10n.tkGlobalCancel)))
      }
      .background(ThemingAssets.Background.secondary.swiftUIColor)
      .navigationBarHidden(true)
      .navigationBarBackButtonHidden()
      .task {
        await viewModel.onAppear()
      }
      .onColorSchemeChange { scheme in
        viewModel.updateCredentialViewModel(with: scheme.rawValue)
      }
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  // MARK: Private

  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  @State private var topSafeAreaHeight: CGFloat = 0
  @StateObject private var viewModel: CredentialDetailViewModel

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

// MARK: - Portrait layout

extension CredentialDetailView {
  private func portraitLayout() -> some View {
    GeometryReader { geometry in
      ScrollView(showsIndicators: false) {
        VStack(spacing: .x6) {
          if let credentialViewModel = viewModel.credentialViewModel {
            credentialCard(credentialViewModel)
              .frame(height: geometry.size.height * 0.8)
          }

          contentSection()
        }
      }
      .refresher {
        await viewModel.refresh()
      }
      .onAppear {
        self.topSafeAreaHeight = geometry.safeAreaInsets.top
      }
      .onChange(of: geometry.safeAreaInsets) { newInsets in
        self.topSafeAreaHeight = newInsets.top
      }
      .padding(.top, -topSafeAreaHeight)
    }
  }
}

// MARK: - Landscape layout

extension CredentialDetailView {
  private func landscapeLayout() -> some View {
    HStack {
      if let credentialViewModel = viewModel.credentialViewModel {
        credentialCard(credentialViewModel)
      }
      ScrollView(showsIndicators: false) {
        contentSection()
      }
      .refresher {
        await viewModel.refresh()
      }
    }
  }
}

// MARK: - Components

extension CredentialDetailView {

  private static let imageSize: CGFloat = 18

  @ViewBuilder
  private func contentSection() -> some View {
    VStack(alignment: .leading, spacing: .x6) {
      ClaimClusterList(viewModel.credential.clusters)
      issuerSection()
      wrongDataSection()
    }
  }

  @ViewBuilder
  private func issuerSection() -> some View {
    if let issuer = viewModel.credentialViewModel?.issuerDisplay {
      SectionView(title: L10n.tkDisplaydeleteDisplaycredential1Title5) {
        HStack(alignment: .center, spacing: .x3) {
          if !dynamicTypeSize.isAccessibilitySize {
            (issuer.image.flatMap(Image.init) ?? Assets.unknownIcon.swiftUIImage)
              .renderingMode(.template)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: Self.imageSize, height: Self.imageSize)
              .foregroundColor(.white)
              .colorMultiply(colorScheme.standardColor())
              .padding(.x2)
              .background(ThemingAssets.Background.secondary.swiftUIColor)
              .clipShape(Circle())
              .accessibilityHidden(true)
          }
          Text(issuer.name ?? L10n.tkErrorNotregisteredTitle)
            .font(.custom.body)
            .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
            .accessibilityLabel(issuer.name ?? L10n.tkErrorNotregisteredTitle)
            .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, .x6)
      }
    }
  }

  private func credentialCard(_ credentialViewModel: CredentialViewModel) -> some View {
    CredentialCard(credentialViewModel) {
      HStack {
        menu()

        Spacer()

        Button(action: viewModel.close, label: {
          ThemingAssets.xmark.swiftUIImage
            .colorMultiply(ThemingAssets.Brand.Core.black.swiftUIColor)
            .frame(width: 32, height: 32)
            .background(.ultraThickMaterial.opacity(0.70))
            .clipShape(.circle)
        })
        .accessibilityLabel(L10n.tkGlobalCloseelfaAlt)
        .accessibilitySortPriority(AccessibilityPriority.x5.rawValue)
        .accessibilityIdentifier(AccessibilityIdentifier.closeButton.rawValue)
      }
      .padding(.top, self.topSafeAreaHeight)
    }
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier(AccessibilityIdentifier.card.rawValue)
    .controlSize(.large)
  }

  @ViewBuilder
  private func menu() -> some View {
    Menu {
      Section {
        Button(action: viewModel.openWrongdata, label: {
          Label(title: { Text(L10n.tkGlobalWrongdata) }, icon: { Assets.warning.swiftUIImage })
        })
        .accessibilityLabel(L10n.tkGlobalWrongdata)
        .accessibilityIdentifier(AccessibilityIdentifier.wrongDataButton.rawValue)
      }

      Button(role: .destructive, action: {
        viewModel.isDeleteCredentialAlertPresented.toggle()
      }, label: {
        Label(L10n.tkDisplaydeleteCredentialmenuPrimarybutton, systemImage: "trash")
      })
      .accessibilityLabel(L10n.tkDisplaydeleteCredentialmenuPrimarybutton)
      .accessibilityIdentifier(AccessibilityIdentifier.deleteButton.rawValue)
    } label: {
      ThemingAssets.elipsis.swiftUIImage
        .colorMultiply(ThemingAssets.Brand.Core.black.swiftUIColor)
        .frame(width: 32, height: 32)
        .background(.ultraThickMaterial.opacity(0.70))
        .clipShape(.circle)
    }
    .accessibilitySortPriority(AccessibilityPriority.x4.rawValue)
    .accessibilityLabel(L10n.tkGlobalMoreoptionsAlt)
    .accessibilityIdentifier(AccessibilityIdentifier.menuButton.rawValue)
  }

  @ViewBuilder
  private func wrongDataSection() -> some View {
    SectionView {
      IconCell(
        image: Assets.warning.swiftUIImage,
        text: L10n.tkReceiveIncorrectdataTitle,
        disclosureIndicator: .navigation,
        onTap: viewModel.openWrongdata)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .padding(.horizontal, .x6)
    }
  }
}

#if DEBUG
#Preview {
  CredentialDetailView(credential: .Mock.sample, router: CredentialDetailRouter())
}
#endif
