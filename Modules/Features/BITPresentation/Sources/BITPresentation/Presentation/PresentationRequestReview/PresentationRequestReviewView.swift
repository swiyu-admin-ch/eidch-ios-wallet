import BITCredential
import BITCredentialShared
import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - PresentationRequestReviewView

public struct PresentationRequestReviewView: View {

  // MARK: Lifecycle

  public init(context: PresentationRequestContext, router: PresentationRouterRoutes) {
    _viewModel = StateObject(wrappedValue: Container.shared.presentationRequestReviewViewModel((context, router)))
  }

  // MARK: Public

  public var body: some View {
    content()
      .accessibilityAction(named: L10n.tkPresentReviewPrimaryButtonAlt) {
        Task { await viewModel.submit() }
      }
      .accessibilityAction(named: L10n.tkPresentReviewSecondaryButtonAlt) {
        Task { await viewModel.deny() }
      }
      .readSize(onChange: { size in
        compression = sizeCategory.isAccessibilityCategory ? .small : UICompressionStyle(height: size.height)
      })
      .navigationBarHidden(true)
      .task {
        if orientation.isPortrait {
          focus = .header
        } else {
          focus = .subtitle
        }
      }
      .onColorSchemeChange { scheme in
        viewModel.updateCredentialViewModel(with: scheme.rawValue)
      }
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "presentationRequestReviewContent"
    case acceptButton
    case denyButton
  }

  // MARK: Private

  private enum Focus: Hashable {
    case header, subtitle
  }

  @Environment(\.sizeCategory) private var sizeCategory
  @State private var compression = UICompressionStyle.normal

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
        .padding(.horizontal, .x6)
        .padding(.top, .x3)
        .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)

      subtitle()
        .padding(.top, .x8)
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
        .background(ThemingAssets.Materials.chrome.swiftUIColor)
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
          .padding(.bottom, .x2)
          .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)
        claimsList(credential)
          .accessibilitySortPriority(AccessibilityPriority.x4.rawValue)
      }
      .padding(.top, .x4)
      .applyScrollViewIfNeeded()
      .safeAreaInset(edge: .bottom) {
        footerButtons()
          .background(ThemingAssets.Materials.chrome.swiftUIColor)
          .accessibilitySortPriority(AccessibilityPriority.x3.rawValue) // not fully working for now...
      }
    }
    .accessibilityElement(children: .contain)
  }

  @ViewBuilder
  private func claimsList(_ compatibleCredential: CompatibleCredential) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(L10n.tkPresentReviewClaimsSectionPrimary(compatibleCredential.requestedClusteredClaims.flatMap(\.claims).count))
        .font(.custom.subheadline)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .padding(.horizontal, .x6)
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
    FooterView {
      ButtonStackView {
        Button { Task { await viewModel.deny() } } label: {
          Label(L10n.tkPresentReviewSecondaryButton, systemImage: "xmark")
            .if(!sizeCategory.isAccessibilityCategory, transform: {
              $0.multilineTextAlignment(.center)
                .lineLimit(1)
            })
            .frame(maxWidth: .infinity)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .accessibilityLabel(L10n.tkPresentReviewSecondaryButtonAlt)
        }
        .buttonStyle(.filledPrimary)
        .controlSize(.large)
        .accessibilityIdentifier(AccessibilityIdentifier.denyButton.rawValue)
        .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)

        Button { Task { await viewModel.submit() } } label: {
          Label(L10n.tkPresentReviewPrimaryButton, systemImage: "checkmark")
            .if(!sizeCategory.isAccessibilityCategory, transform: {
              $0.multilineTextAlignment(.center)
                .lineLimit(1)
            })
            .frame(maxWidth: .infinity)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .accessibilityLabel(L10n.tkPresentReviewPrimaryButtonAlt)
        }
        .buttonStyle(.filledSecondary)
        .controlSize(.large)
        .accessibilityIdentifier(AccessibilityIdentifier.acceptButton.rawValue)
        .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)
      }
    }
  }
}

// MARK: - Loading

extension PresentationRequestReviewView {
  @ViewBuilder
  private func loadingView(_ credential: Credential) -> some View {
    if orientation.isPortrait {
      portraitLoadingView(credential)
    } else {
      landscapeLoadingView(credential)
    }
  }

  @ViewBuilder
  private func portraitLoadingView(_ credential: Credential) -> some View {
    VStack {
      actorHeader()
        .padding(.horizontal, .x6)
        .padding(.top, .x3)
        .padding(.bottom, .x4)

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
      .padding(.top, .x6)
      .padding(.bottom, .x10)
      .padding(.horizontal, .x6)
      .background(ThemingAssets.Background.secondary.swiftUIColor)
      .clipShape(RoundedCorner(radius: .x8, corners: [.topLeft, .topRight]))
    }
    .ignoresSafeArea(edges: .bottom)
  }

  @ViewBuilder
  private func landscapeLoadingView(_ credential: Credential) -> some View {
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
    if let verifierDisplay = viewModel.verifierDisplay {
      ActorHeaderView(verifier: verifierDisplay)
        .accessibilityFocused($focus, equals: .header)
    }
  }

  @ViewBuilder
  private func subtitle() -> some View {
    Text(L10n.tkPresentReviewCredentialSectionPrimary)
      .font(.custom.subheadline)
      .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
      .accessibilityFocused($focus, equals: .subtitle)
  }

  @ViewBuilder
  private func credentialBoxWithSubtitle(_ credential: Credential) -> some View {
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
