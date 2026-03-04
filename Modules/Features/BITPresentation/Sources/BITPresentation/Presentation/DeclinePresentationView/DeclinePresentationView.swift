import BITCredential
import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - DeclinePresentationView

struct DeclinePresentationView: View {

  // MARK: Lifecycle

  init(context: PresentationRequestContext, router: PresentationInternalRoutes) {
    self.router = router
    _viewModel = StateObject(wrappedValue: Container.shared.declinePresentationViewModel((context, router)))
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "declinePresentationContent"
    case declineButton
  }

  var body: some View {
    VStack {
      ActorHeaderView(verifier: viewModel.verifierDisplay, topInset: topInset) { badgeType in
        router.badgeInformation(badgeType: badgeType)
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
    .onAppear(perform: {
      isAccessibilityTitleFocused = true
    })
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  // MARK: Private

  @Environment(\.sizeCategory) private var sizeCategory

  @State private var topInset: CGFloat = 0
  @State private var availableWidth: CGFloat = 0
  @State private var compression = UICompressionStyle.normal

  @StateObject private var viewModel: DeclinePresentationViewModel
  @AccessibilityFocusState(for: .voiceOver) private var isAccessibilityTitleFocused: Bool

  private let router: PresentationInternalRoutes

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

      AsyncButton(action: viewModel.declineRequest) {
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
  DeclinePresentationView(context: .Mock.vcSdJwtSample, router: PresentationRouter())
}
#endif
