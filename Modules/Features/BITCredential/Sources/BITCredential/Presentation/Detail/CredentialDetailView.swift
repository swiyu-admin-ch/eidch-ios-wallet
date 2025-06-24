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
      .navigationBarHidden(true)
      .navigationBarBackButtonHidden()
      .task {
        await viewModel.onAppear()
      }
      .onColorSchemeChange { scheme in
        viewModel.updateCredentialViewModel(with: scheme.rawValue)
      }
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
        VStack(spacing: .x10) {
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
  private func contentSection () -> some View {
    VStack(alignment: .leading, spacing: .x5) {
      claimsSection()

      issuerSection()
        .padding(.top, .x4)

      wrongDataSection()
        .padding(.top, .x4)
    }
    .accessibilityElement(children: .contain)
    .accessibilityLabel(L10n.tkReceiveCredentialOfferContentSectionPrimary)
    .accessibilitySortPriority(10)
  }

  @ViewBuilder
  private func claimsSection() -> some View {
    VStack(alignment: .leading) {
      Text(L10n.tkDisplaydeleteDisplaycredential1Title2)
        .font(.custom.body)
        .padding(.top, .x4)
        .padding(.leading, .x6)
        .accessibilityLabel(L10n.tkDisplaydeleteDisplaycredential1Title2)
        .accessibilitySortPriority(100)

      Divider()

      LazyVStack {
        let clusterDisplayClaims = viewModel.credential.clusters.flatMap(\.claims)
        ClaimListView(clusterDisplayClaims)
      }
    }
  }

  @ViewBuilder
  private func issuerSection() -> some View {
    VStack(alignment: .leading) {
      Text(L10n.tkDisplaydeleteDisplaycredential1Title5)
        .font(.custom.body)
        .padding(.leading, .x6)
        .accessibilitySortPriority(80)
      Divider()
      issuerCell()
    }
  }

  @ViewBuilder
  private func issuerCell() -> some View {
    if let issuer = viewModel.credentialViewModel?.issuerDisplay {
      let image = if let image = issuer.image {
        Image(data: image) ?? Image(systemName: "circle.fill")
      } else {
        Image(systemName: "circle.fill")
      }

      HStack(alignment: .center, spacing: .x4) {
        if !dynamicTypeSize.isAccessibilitySize {
          image
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

        HStack(spacing: .x2) {
          Text(issuer.name ?? L10n.tkErrorNotregisteredTitle)
            .font(.custom.body)
            .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
            .accessibilityLabel(issuer.name ?? L10n.tkErrorNotregisteredTitle)
            .multilineTextAlignment(.leading)
        }
        .padding(.trailing, .x6)

        Spacer()
      }
      .padding(.leading, .x6)
      .padding(.bottom, -2)

      let leadingPadding = dynamicTypeSize < .accessibility3 ? Self.imageSize + .x4 * 2 + .x6 : .x4 + .x6
      Divider()
        .padding(.leading, leadingPadding)
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
        .accessibilitySortPriority(50)
      }
      .padding(.top, self.topSafeAreaHeight)
    }
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
      }

      Button(role: .destructive, action: {
        viewModel.isDeleteCredentialAlertPresented.toggle()
      }, label: {
        Label(L10n.tkDisplaydeleteCredentialmenuPrimarybutton, systemImage: "trash")
      })
      .accessibilityLabel(L10n.tkDisplaydeleteCredentialmenuPrimarybutton)
    } label: {
      ThemingAssets.elipsis.swiftUIImage
        .colorMultiply(ThemingAssets.Brand.Core.black.swiftUIColor)
        .frame(width: 32, height: 32)
        .background(.ultraThickMaterial.opacity(0.70))
        .clipShape(.circle)
    }
    .accessibilitySortPriority(75)
    .accessibilityLabel(L10n.tkGlobalMoreoptionsAlt)
  }

  @ViewBuilder
  private func wrongDataSection() -> some View {
    VStack(alignment: .leading) {
      Divider()
      IconKeyValueCell(
        key: "",
        value: L10n.tkReceiveIncorrectdataTitle,
        image: Assets.warning.swiftUIImage,
        disclosureIndicator: Image(systemName: "chevron.right"),
        onTap: viewModel.openWrongdata)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .padding(.leading, .x6)
    }
  }
}

#if DEBUG
#Preview {
  CredentialDetailView(credential: .Mock.sample, router: CredentialDetailRouter())
}
#endif
