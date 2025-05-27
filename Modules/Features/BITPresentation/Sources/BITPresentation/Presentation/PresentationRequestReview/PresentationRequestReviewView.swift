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
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
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
    VStack(alignment: .leading) {
      actorHeader()
        .padding(.horizontal, .x6)
        .padding(.top, .x3)

      subtitle()
        .padding(.vertical, .x4)
        .padding(.horizontal, .x6)

      CredentialBox(credential: credential.credential, compression: compression)

      claimsList(credential)
        .padding(.top, .x2)
      Spacer() // Pushes buttons down if VStack is not filling screen
    }
    .applyScrollViewIfNeeded()
    .safeAreaInset(edge: .bottom) {
      footerButtons()
        .background(ThemingAssets.Materials.chrome.swiftUIColor)
        .accessibilitySortPriority(-1)
    }
  }

  @ViewBuilder
  private func landscapeResultView(_ credential: CompatibleCredential) -> some View {
    HStack(spacing: .x5) {
      credentialBoxWithSubtitle(credential.credential)
        .accessibilitySortPriority(1)
      VStack(alignment: .leading) {
        actorHeader()
          .padding(.bottom, .x3)
        claimsList(credential)
        Spacer() // Pushes buttons down if VStack is not filling screen
      }
      .padding(.top, .x4)
      .applyScrollViewIfNeeded()
      .safeAreaInset(edge: .bottom) {
        footerButtons()
          .background(ThemingAssets.Materials.chrome.swiftUIColor)
          .accessibilitySortPriority(-1)
      }
    }
  }

  @ViewBuilder
  private func claimsList(_ compatibleCredential: CompatibleCredential) -> some View {
    VStack(alignment: .leading) {
      Text(L10n.tkPresentReviewClaimsSectionPrimary(compatibleCredential.requestedClaims.count))
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .padding(.horizontal, .x6)
        .accessibilityAddTraits(.isHeader)

      Divider()

      LazyVStack {
        PresentationRequestClaimList(compatibleCredential.requestedClaims)
          .padding(.leading, .x6)
      }
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
        }
        .buttonStyle(.filledPrimary)
        .controlSize(.large)
        .accessibilityIdentifier(AccessibilityIdentifier.denyButton.rawValue)

        Button { Task { await viewModel.submit() } } label: {
          Label(L10n.tkPresentReviewPrimaryButton, systemImage: "checkmark")
            .if(!sizeCategory.isAccessibilityCategory, transform: {
              $0.multilineTextAlignment(.center)
                .lineLimit(1)
            })
            .frame(maxWidth: .infinity)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
        }
        .buttonStyle(.filledSecondary)
        .controlSize(.large)
        .accessibilityIdentifier(AccessibilityIdentifier.acceptButton.rawValue)
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
          CredentialCard(credential)
            .controlSize(.small)

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
      .font(.custom.title3)
      .foregroundStyle(ThemingAssets.Brand.Core.navyBlue.swiftUIColor)
      .accessibilityAddTraits(.isHeader)
      .accessibilityFocused($focus, equals: .subtitle)
  }

  @ViewBuilder
  private func credentialBoxWithSubtitle(_ credential: Credential) -> some View {
    VStack {
      subtitle()
        .padding(.top, .x4)
        .fixedSize()
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
      CredentialBox(credential: credential, compression: compression)
    }
  }
}

#if DEBUG
#Preview {
  PresentationRequestReviewView(context: .Mock.vcSdJwtSample, router: PresentationRouter())
}
#endif
