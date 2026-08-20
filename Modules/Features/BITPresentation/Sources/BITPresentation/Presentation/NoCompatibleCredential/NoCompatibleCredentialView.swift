import BITCredential
import BITL10n
import BITNavigation
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - NoCompatibleCredentialView

struct NoCompatibleCredentialView: View {

  // MARK: Lifecycle

  init(context: PresentationRequestContext) {
    _viewModel = State(wrappedValue: Container.shared.noCompatibleCredentialViewModel(context))
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "noCompatibleCredentialContent"
    case declineButton
  }

  var body: some View {
    VStack {
      ActorHeaderView(verifier: viewModel.verifierDisplay, topInset: topInset) { actorInformation in
        navigator.navigate(to: PresentationDestinations.actorInformation(actorInformation))
      }
      .padding(.bottom, .x3)

      content
    }
    .applyScrollViewIfNeeded()
    .toolbar(.hidden)
    .navigationBarBackButtonHidden()
    .ignoresSafeArea(edges: .vertical)
    .readSize(onChange: { size in
      compression = sizeCategory.isAccessibilityCategory ? .small : UICompressionStyle(height: size.height)
      availableWidth = size.width
    })
    .readSafeAreaInsets(onChange: { insets in
      topInset = insets.top
    })
    .background(ThemingAssets.Background.secondary.swiftUIColor)
    .navigate(to: $viewModel.destination)
    .onAppear(perform: {
      isAccessibilityTitleFocused = true
    })
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator
  @Environment(\.sizeCategory) private var sizeCategory

  @State private var topInset: CGFloat = 0
  @State private var availableWidth: CGFloat = 0
  @State private var compression = UICompressionStyle.normal

  @State private var viewModel: NoCompatibleCredentialViewModel
  @AccessibilityFocusState(for: .voiceOver) private var isAccessibilityTitleFocused: Bool

  private var content: some View {
    VStack {
      Spacer()
      if sizeCategory < .accessibilityExtraLarge {
        Assets.presentationError.swiftUIImage
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 56, height: 56)
          .accessibilityHidden(true)
      }

      VStack(spacing: .x1) {
        Text(L10n.tkPresentCredentialNotFoundTitle)
          .multilineTextAlignment(.center)
          .font(.custom.body)
          .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        Text(L10n.tkPresentCredentialNotFoundBody)
          .multilineTextAlignment(.center)
          .font(.custom.body)
          .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor.opacity(0.7))
      }
      .padding(.top, .x1)

      Spacer(minLength: compression.isCompressed ? .x4 : .x6)

      AsyncButton(action: {
        await viewModel.declineRequest(navigator)
      }) {
        Text(L10n.tkGlobalClose)
      }
      .buttonStyle(.primary)
      .controlSize(.large)
      .accessibilityIdentifier(AccessibilityIdentifier.declineButton.rawValue)
    }
    .frame(maxWidth: .infinity)
    .padding(.top, compression.isCompressed ? .x4 : .x6)
    .padding(.bottom, .x10)
    .padding(.horizontal, .x6)
    .background(ThemingAssets.Background.tertiary.swiftUIColor)
    .clipShape(RoundedCorner(radius: .x8, corners: [.topLeft, .topRight]))
    .accessibilityElement(children: .contain)
  }
}

#if DEBUG
#Preview {
  NoCompatibleCredentialView(context: .Mock.vcSdJwtSample)
}
#endif
