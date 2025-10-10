import BITCredential
import BITCredentialShared
import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - PresentationRequestReviewView

struct PresentationRequestReviewView: View {

  // MARK: Lifecycle

  init(context: PresentationRequestContext, router: PresentationInternalRoutes) {
    _viewModel = StateObject(wrappedValue: Container.shared.presentationRequestReviewViewModel((context, router)))
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "presentationRequestReviewContent"
    case acceptButton
    case denyButton
  }

  var body: some View {
    content()
      .accessibilityAction(named: L10n.tkPresentReviewPrimaryButtonAlt) {
        Task { await viewModel.submit() }
      }
      .accessibilityAction(named: L10n.tkPresentReviewSecondaryButtonAlt) {
        Task { await viewModel.deny() }
      }
      .ignoresSafeArea(edges: .top)
      .readSize(onChange: { size in
        compression = sizeCategory.isAccessibilityCategory ? .small : UICompressionStyle(height: size.height)
      })
      .readSafeAreaInsets(onChange: { insets in
        topInset = insets.top
      })
      .navigationBarHidden(true)
      .task {
        if orientation.isPortrait {
          focus = .header
        } else {
          focus = .subtitle
        }
      }
      .background(ThemingAssets.Background.secondary.swiftUIColor)
      .onColorSchemeChange { scheme in
        viewModel.updateCredentialViewModel(with: scheme.rawValue)
      }
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  // MARK: Private

  private enum Focus: Hashable {
    case header, subtitle
  }

  @Environment(\.sizeCategory) private var sizeCategory
  @State private var compression = UICompressionStyle.normal
  @State private var topInset: CGFloat = 0

  @StateObject private var viewModel: PresentationRequestReviewViewModel

  @FocusState private var inputFocused: Bool
  @AccessibilityFocusState private var focus: Focus?

  @Orientation private var orientation

  @ViewBuilder
  private func content() -> some View {
    switch viewModel.state {
    case .result:
      resultView(viewModel.credential)
    case .loading:
      loadingView(viewModel.credential.credential)
    }
  }
}

// MARK: - Result

extension PresentationRequestReviewView {
  @ViewBuilder
  private func resultView(_ credential: CompatibleCredential) -> some View {
    if orientation.isPortrait {
      portraitResultView(credential)
    } else {
      landscapeResultView(credential)
    }
  }

  @ViewBuilder
  private func portraitResultView(_ credential: CompatibleCredential) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      actorHeader()
        .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)

      subtitle()
        .padding(.top, .x3)
        .padding(.bottom, .x3)
        .padding(.horizontal, .x6)
        .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)

      if let credentialViewModel = viewModel.credentialViewModel {
        CredentialBox(credentialViewModel, compression: compression)
          .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
      }

      claimsList(credential)
        .padding(.top, .x4)
        .accessibilitySortPriority(AccessibilityPriority.x5.rawValue)
      Spacer() // Pushes buttons down if VStack is not filling screen
    }
    .applyScrollViewIfNeeded()
    .safeAreaInset(edge: .bottom) {
      footerButtons()
        .accessibilitySortPriority(AccessibilityPriority.x4.rawValue) // not fully working for now...
        .accessibilityElement(children: .contain)
    }
  }

  @ViewBuilder
  private func landscapeResultView(_ credential: CompatibleCredential) -> some View {
    HStack(spacing: .x5) {
      credentialBoxWithSubtitle(credential.credential)
        .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)
      VStack(alignment: .leading, spacing: 0) {
        actorHeader()
          .padding(.bottom, .x3)
          .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)
        claimsList(credential)
          .accessibilitySortPriority(AccessibilityPriority.x4.rawValue)
      }
      .applyScrollViewIfNeeded()
      .safeAreaInset(edge: .bottom) {
        footerButtons()
          .accessibilitySortPriority(AccessibilityPriority.x3.rawValue) // not fully working for now...
      }
    }
    .accessibilityElement(children: .contain)
  }

  @ViewBuilder
  private func claimsList(_ compatibleCredential: CompatibleCredential) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(L10n.tkPresentReviewClaimsSectionPrimary(compatibleCredential.requestedClusteredClaims.flatMap(\.claims).count))
        .accessibilityAddTraits(.isHeader)
        .font(.custom.subheadline)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .padding(.horizontal, .x2)
        .padding(.vertical, .x3)
      VStack {
        ClaimClusterList(compatibleCredential.requestedClusteredClaims)
        Spacer() // Pushes buttons down if VStack is not filling screen
      }
      .padding(.vertical, .x4)
      .background(ThemingAssets.Background.secondary.swiftUIColor)
      .cornerRadius(.CornerRadius.xl)
    }
  }

  @ViewBuilder
  private func footerButtons() -> some View {
    ButtonSheet(colorConfig: .secondary) {
      AdaptiveButtonStack {
        Button { Task { await viewModel.submit() } } label: {
          Label(L10n.tkPresentReviewPrimaryButton, systemImage: "checkmark")
            .frame(maxWidth: .infinity)
            .lineLimit(1)
            .accessibilityLabel(L10n.tkPresentReviewPrimaryButtonAlt)
        }
        .buttonStyle(.tertiary)
        .controlSize(.large)
        .accessibilityIdentifier(AccessibilityIdentifier.acceptButton.rawValue)
        .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)
      } secondary: {
        Button { Task { await viewModel.deny() } } label: {
          Label(L10n.tkPresentReviewSecondaryButton, systemImage: "xmark")
            .frame(maxWidth: .infinity)
            .lineLimit(1)
            .accessibilityLabel(L10n.tkPresentReviewSecondaryButtonAlt)
        }
        .buttonStyle(.primary)
        .controlSize(.large)
        .accessibilityIdentifier(AccessibilityIdentifier.denyButton.rawValue)
        .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)
      }
    }
  }
}

// MARK: - Loading

extension PresentationRequestReviewView {
  @ViewBuilder
  private func loadingView(_ credential: VerifiableCredential) -> some View {
    if orientation.isPortrait {
      portraitLoadingView(credential)
    } else {
      landscapeLoadingView(credential)
    }
  }

  @ViewBuilder
  private func portraitLoadingView(_ credential: VerifiableCredential) -> some View {
    VStack {
      actorHeader()
        .padding(.bottom, .x3)

      VStack {
        Spacer()
        HStack(spacing: .x3) {
          Spacer()
          if let credentialViewModel = viewModel.credentialViewModel {
            CredentialCard(credentialViewModel)
              .controlSize(.small)
          }
          Spacer()
        }
        Spacer(minLength: .x4)
        loader()
      }
      .padding(.bottom, .x10)
      .padding(.horizontal, .x6)
      .background(ThemingAssets.Background.secondary.swiftUIColor)
      .clipShape(RoundedCorner(radius: .x8, corners: [.topLeft, .topRight]))
    }
    .ignoresSafeArea(edges: .bottom)
  }

  @ViewBuilder
  private func landscapeLoadingView(_ credential: VerifiableCredential) -> some View {
    HStack(spacing: .x5) {
      credentialBoxWithSubtitle(credential)
      loader()
        .frame(maxWidth: .infinity)
    }
  }

  @ViewBuilder
  private func loader() -> some View {
    VStack(spacing: .x3) {
      ProgressView()
        .controlSize(.large)

      if viewModel.showLoadingMessage {
        Text(L10n.tkPresentReviewLoading)
          .font(.custom.body)
          .accessibilityLabel(L10n.tkPresentReviewLoadingAlt)
      }
    }
    .animation(.default, value: viewModel.showLoadingMessage)
  }
}

// MARK: Components

extension PresentationRequestReviewView {
  @ViewBuilder
  private func actorHeader() -> some View {
    ActorHeaderView(verifier: viewModel.verifierDisplay, topInset: topInset)
      .accessibilityFocused($focus, equals: .header)
  }

  @ViewBuilder
  private func subtitle() -> some View {
    Text(L10n.tkPresentReviewCredentialSectionPrimary)
      .font(.custom.subheadline)
      .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
      .accessibilityFocused($focus, equals: .subtitle)
      .accessibilityAddTraits(.isHeader)
  }

  @ViewBuilder
  private func credentialBoxWithSubtitle(_ credential: VerifiableCredential) -> some View {
    VStack {
      subtitle()
        .padding(.top, .x4)
        .fixedSize()
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
      if let credentialViewModel = viewModel.credentialViewModel {
        CredentialBox(credentialViewModel, compression: compression)
      }
    }
  }
}

#if DEBUG
#Preview {
  PresentationRequestReviewView(context: .Mock.vcSdJwtSample, router: PresentationRouter())
}
#endif
