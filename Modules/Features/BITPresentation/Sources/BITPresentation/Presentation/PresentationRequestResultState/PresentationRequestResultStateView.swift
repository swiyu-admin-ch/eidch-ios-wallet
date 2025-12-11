import BITCredential
import BITCredentialShared
import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - PresentationRequestResultStateView

struct PresentationRequestResultStateView: View {

  // MARK: Lifecycle

  init(state: PresentationRequestResultState, context: PresentationRequestContext, router: PresentationInternalRoutes) {
    self.router = router
    _viewModel = StateObject(wrappedValue: Container.shared.presentationRequestResultStateViewModel((state, context, router)))
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "presentationRequestResultStateContent"
    case successContent
    case finishButton
  }

  var body: some View {
    VStack {
      ActorHeaderView(verifier: viewModel.verifierDisplay, topInset: topInset) { badgeType in
        router.badgeInformation(badgeType: badgeType)
      }.padding(.bottom, .x3)
      stateView()
    }
    .applyScrollViewIfNeeded()
    .ignoresSafeArea(edges: .bottom)
    .ignoresSafeArea(edges: .top)
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
  @State private var compression = UICompressionStyle.normal
  @State private var availableWidth: CGFloat = 0
  @State private var topInset: CGFloat = 0

  @AccessibilityFocusState(for: .voiceOver)
  private var isAccessibilityTitleFocused: Bool

  @StateObject private var viewModel: PresentationRequestResultStateViewModel

  private let router: PresentationInternalRoutes

  @ViewBuilder
  private func stateView() -> some View {
    VStack {
      Spacer()
      if sizeCategory < .accessibilityExtraLarge {
        viewModel.state.icon
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 56, height: 56)
          .accessibilityLabel(viewModel.state.sheetAccessibilityLabel)
          .accessibilityRemoveTraits(.isImage)
          .accessibilityFocused($isAccessibilityTitleFocused)
      }
      content()
      Spacer(minLength: compression.isCompressed ? .x4 : .x6)
      buttons()
    }
    .frame(maxWidth: .infinity)
    .padding(.top, compression.isCompressed ? .x4 : .x6)
    .padding(.bottom, .x10)
    .padding(.horizontal, .x6)
    .background(viewModel.state.backgroundColor)
    .clipShape(RoundedCorner(radius: .x8, corners: [.topLeft, .topRight]))
    .accessibilityElement(children: .contain)
  }

  @ViewBuilder
  private func content() -> some View {
    switch viewModel.state {
    case .success(let claims):
      successView(claims: claims)
    case .invalidCredential(let claims):
      invalidCredentialView(claims: claims)
    case .deny:
      denyView()
    case .cancelled:
      errorMessages(title: L10n.tkPresentResultCanceledVerificationPrimary, subtitle: L10n.tkPresentResultCanceledVerificationSecondary)
    case .error:
      errorMessages(title: L10n.tkPresentResultErrorPrimary, subtitle: L10n.tkPresentResultErrorSecondary)
    }
  }

  @ViewBuilder
  private func successView(claims: [CredentialClaim]) -> some View {
    Text(L10n.tkPresentResultSuccessPrimary)
      .multilineTextAlignment(.center)
      .font(.custom.body)
      .foregroundStyle(ThemingAssets.Brand.Core.firGreenLabel.swiftUIColor)
      .padding(.bottom, compression.isCompressed ? .x2 : .x4)
    claimsList(claims, cell: {
      claimCell($0, image: Assets.checkmark.swiftUIImage, imageColor: ThemingAssets.Brand.Core.firGreen.swiftUIColor)
    })
    .background(ThemingAssets.Brand.Core.firGreenLabel.swiftUIColor)
    .foregroundStyle(ThemingAssets.Brand.Core.firGreen.swiftUIColor)
    .clipShape(.rect(cornerRadius: .CornerRadius.xs))
    .accessibilityIdentifier(AccessibilityIdentifier.successContent.rawValue)
  }

  @ViewBuilder
  private func invalidCredentialView(claims: [CredentialClaim]) -> some View {
    VStack {
      Text(L10n.tkPresentResultInvalidCredentialPrimary)
        .multilineTextAlignment(.center)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
      Text(L10n.tkPresentResultInvalidCredentialSecondary)
        .multilineTextAlignment(.center)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
    }
    .padding(.bottom, compression.isCompressed ? .x2 : .x4)

    claimsList(claims, cell: {
      claimCell($0, image: Assets.checkmark.swiftUIImage)
    })
    .background(ThemingAssets.Background.primary.swiftUIColor)
    .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
    .clipShape(.rect(cornerRadius: .CornerRadius.xs))
  }

  @ViewBuilder
  private func claimsList(_ claims: [CredentialClaim], @ViewBuilder cell: @escaping (CredentialClaim) -> some View) -> some View {
    LazyVStack(alignment: .leading, spacing: .x1) {
      ForEach(claims, id: \.id) { claim in
        cell(claim)
      }
    }
    .padding(.x4)
    .frame(maxWidth: 400)
  }

  @ViewBuilder
  private func claimCell(_ claim: CredentialClaim, image: Image = Assets.checkmark.swiftUIImage, imageColor: Color? = nil) -> some View {
    HStack(alignment: .top, spacing: .x1) {
      if sizeCategory < .accessibilityExtraLarge {
        image
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 17, height: 17)
          .padding(.top, 2)
          .accessibilityHidden(true)
      }
      Text(claim.preferredDisplay.name ?? claim.key)
        .font(.custom.body)
    }
  }

  @ViewBuilder
  private func denyView() -> some View {
    Text(L10n.tkPresentResultDeclinedPrimary)
      .multilineTextAlignment(.center)
      .font(.custom.body)
      .foregroundStyle(ThemingAssets.Brand.Core.navyBlueLabel.swiftUIColor)
      .padding(.bottom, compression.isCompressed ? .x2 : .x4)
  }

  @ViewBuilder
  private func errorMessages(title: String, subtitle: String) -> some View {
    VStack(spacing: .x1) {
      Text(title)
        .multilineTextAlignment(.center)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
      Text(subtitle)
        .multilineTextAlignment(.center)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor.opacity(0.7))
    }
    .padding(.top, .x1)
  }

  @ViewBuilder
  private func buttons() -> some View {
    switch viewModel.state {
    case .success:
      finishButton()
        .buttonStyle(.firGreen)
    case .deny:
      finishButton()
        .buttonStyle(.navyBlue)
    case .cancelled,
         .invalidCredential:
      finishButton()
        .buttonStyle(.bezeled)
    case .error:
      errorButtons()
    }
  }

  @ViewBuilder
  private func finishButton() -> some View {
    AsyncButton(action: viewModel.finish) {
      Text(L10n.tkGlobalFinish)
    }
    .controlSize(.large)
    .accessibilityIdentifier(AccessibilityIdentifier.finishButton.rawValue)
  }

  @ViewBuilder
  private func errorButtons() -> some View {
    AdaptiveButtonStack {
      Button { viewModel.retry() } label: {
        Text(L10n.tkPresentResultErrorButtonRetry)
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.bezeled)
      .controlSize(.large)
    } secondary: {
      AsyncButton(action: viewModel.finish) {
        Text(L10n.tkGlobalFinish)
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.plain)
      .controlSize(.large)
    }
  }
}

extension PresentationRequestResultState {
  fileprivate var backgroundColor: Color {
    switch self {
    case .success:
      ThemingAssets.Brand.Core.firGreen.swiftUIColor
    case .deny:
      ThemingAssets.Brand.Core.navyBlue.swiftUIColor
    case .cancelled,
         .error,
         .invalidCredential:
      ThemingAssets.Background.tertiary.swiftUIColor
    }
  }

  fileprivate var icon: Image {
    switch self {
    case .success:
      Assets.presentationSuccess.swiftUIImage
    case .deny:
      Assets.presentationDeny.swiftUIImage
    case .invalidCredential:
      Assets.invalid.swiftUIImage
    case .cancelled,
         .error:
      Assets.presentationError.swiftUIImage
    }
  }

  fileprivate var sheetAccessibilityLabel: String {
    switch self {
    case .deny,
         .invalidCredential,
         .success:
      L10n.tkPresentResultConfirmAlt
    case .cancelled,
         .error:
      L10n.tkPresentResultWarningAlt
    }
  }
}

#if DEBUG
#Preview {
  PresentationRequestResultStateView(state: .invalidCredential(claims: CredentialClaim.Mock.array), context: .Mock.vcSdJwtSample, router: PresentationRouter())
}
#endif
