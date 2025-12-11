import BITCredential
import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - CompatibleCredentialView

struct CompatibleCredentialView: View {

  // MARK: Lifecycle

  init(
    context: PresentationRequestContext,
    router: PresentationInternalRoutes = Container.shared.presentationRouter())
  {
    self.router = router
    _viewModel = StateObject(wrappedValue: Container.shared.compatibleCredentialViewModel((context, router)))
  }

  // MARK: Internal

  @StateObject var viewModel: CompatibleCredentialViewModel

  var body: some View {
    GeometryReader { reader in
      List {
        Section {} header: {
          ActorHeaderView(verifier: viewModel.verifierDisplay, topInset: topInset) { badgeType in
            router.badgeInformation(badgeType: badgeType)
          }.frame(width: reader.size.width)
        }
        .textCase(nil)
        .listRowInsets(EdgeInsets(top: .x1, leading: 0, bottom: 0, trailing: 0))
        credentialListSection
          .textCase(nil)
      }
      .onAppear(perform: {
        UICollectionView.appearance().contentInset.top = -10 // needed that the ActorHeaderView goes right to the top
      })
      .background(ThemingAssets.Background.secondary.swiftUIColor)
      .navigationBarHidden(true)
      .listStyle(.insetGrouped)
      .ignoresSafeArea(edges: .top)
      .safeAreaInset(edge: .bottom) {
        footer
      }
      .onColorSchemeChange { scheme in
        viewModel.updateCredentialViewModels(with: scheme.rawValue)
      }
      .readSafeAreaInsets(onChange: { insets in
        topInset = insets.top
      })
    }
  }

  // MARK: Private

  @Environment(\.sizeCategory) private var sizeCategory

  @State private var listBottomPadding: CGFloat = 0
  @State private var topInset: CGFloat = 0

  private let router: PresentationInternalRoutes

  private var credentialListSection: some View {
    Section {
      CompatibleCredentialListView(viewModels: viewModel.credentialViewModels) { credentialViewModel in
        viewModel.didSelect(credential: credentialViewModel.credential)
      }
    } header: {
      Text(L10n.tkPresentCompatibleCredentialsPrimary)
        .font(.custom.title2Emphasized)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
    }
  }

  private var footer: some View {
    ButtonSheet(colorConfig: .secondary) {
      Button(action: viewModel.cancel) {
        Label(L10n.tkGlobalCancel, systemImage: "xmark")
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.primary)
      .controlSize(.large)
    }
  }

}

#if DEBUG
#Preview {
  CompatibleCredentialView(context: .Mock.vcSdJwtWithIdentityTrust)
}
#endif
