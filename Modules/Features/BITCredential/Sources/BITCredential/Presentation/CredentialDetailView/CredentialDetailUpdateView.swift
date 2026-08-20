import BITCredentialShared
import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - CredentialDetailUpdateView

struct CredentialDetailUpdateView: View {

  // MARK: Lifecycle

  init(credential: CredentialProtocol) {
    _viewModel = State(initialValue: Container.shared.credentialDetailUpdateViewModel(credential))
  }

  init(issuerDisplay: CredentialIssuerDisplay?) {
    _viewModel = State(initialValue: Container.shared.credentialDetailUpdateInfoViewModel(issuerDisplay))
  }

  // MARK: Internal

  var body: some View {
    Content(
      title: viewModel.title,
      bodyText: viewModel.bodyText,
      issuerDisplay: viewModel.issuerDisplay,
      isLoading: viewModel.isLoading,
      isErrorPresented: viewModel.isErrorPresented,
      errorTitle: viewModel.errorTitle,
      errorMessage: viewModel.errorMessage,
      contentAccessibilityIdentifier: viewModel.contentAccessibilityIdentifier,
      errorAccessibilityIdentifier: viewModel.errorAccessibilityIdentifier,
      primaryButtonTitle: viewModel.primaryButtonTitle,
      primaryButtonAccessibilityIdentifier: viewModel.primaryButtonAccessibilityIdentifier,
      primaryAction: {
        Task {
          await viewModel.primaryAction { refreshedCredential in
            navigator.returnToCheckpoint(CredentialDetailCheckpoints.refreshedCredential, value: refreshedCredential)
          }
        }
      },
      closeErrorAction: viewModel.hideError)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      .background(ThemingAssets.Background.secondary.swiftUIColor.ignoresSafeArea())
      .navigationBar(.secondaryScroll, scrollEdgeAppearance: .secondary)
      .navigationBarBackButtonHidden()
      .navigationTitle(viewModel.title)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar(content: toolbarContent)
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  @State private var viewModel: CredentialDetailUpdateViewModel

  @ToolbarContentBuilder
  private func toolbarContent() -> some ToolbarContent {
    ToolbarItem(placement: .topBarLeading) {
      Button(action: { navigator.pop() }, label: {
        Image(systemName: "chevron.backward")
      })
      .accessibilityLabel(L10n.tkGlobalBack)
      .accessibilityIdentifier(viewModel.closeButtonAccessibilityIdentifier)
    }
  }
}

// MARK: CredentialDetailUpdateView.Content

extension CredentialDetailUpdateView {
  fileprivate struct Content: View {

    // MARK: Lifecycle

    init(
      title: String,
      bodyText: String,
      issuerDisplay: CredentialIssuerDisplay?,
      isLoading: Bool,
      isErrorPresented: Bool,
      errorTitle: String?,
      errorMessage: String,
      contentAccessibilityIdentifier: String,
      errorAccessibilityIdentifier: String,
      primaryButtonTitle: String?,
      primaryButtonAccessibilityIdentifier: String,
      primaryAction: (() -> Void)?,
      closeErrorAction: @escaping () -> Void)
    {
      self.title = title
      self.bodyText = bodyText
      self.issuerDisplay = issuerDisplay
      self.isLoading = isLoading
      self.isErrorPresented = isErrorPresented
      self.errorTitle = errorTitle
      self.errorMessage = errorMessage
      self.contentAccessibilityIdentifier = contentAccessibilityIdentifier
      self.errorAccessibilityIdentifier = errorAccessibilityIdentifier
      self.primaryButtonTitle = primaryButtonTitle
      self.primaryButtonAccessibilityIdentifier = primaryButtonAccessibilityIdentifier
      self.primaryAction = primaryAction
      self.closeErrorAction = closeErrorAction
    }

    // MARK: Internal

    var body: some View {
      content
        .disabled(isLoading)
        .loadingOverlay(
          isPresented: isLoading,
          message: L10n.tkDisplayrefreshLoadingTitle,
          accessibility: .voiceOver())
        .overlay(alignment: .top) {
          errorNotificationView()
        }
        .animation(.easeInOut(duration: 0.2), value: isErrorPresented)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(contentAccessibilityIdentifier)
    }

    // MARK: Private

    private let title: String
    private let bodyText: String
    private let issuerDisplay: CredentialIssuerDisplay?
    private let isLoading: Bool
    private let isErrorPresented: Bool
    private let errorTitle: String?
    private let errorMessage: String
    private let contentAccessibilityIdentifier: String
    private let errorAccessibilityIdentifier: String
    private let primaryButtonTitle: String?
    private let primaryButtonAccessibilityIdentifier: String
    private let primaryAction: (() -> Void)?
    private let closeErrorAction: () -> Void

    private var content: some View {
      VStack(alignment: .leading, spacing: .x4) {
        SectionView(minHeight: nil) {
          VStack(alignment: .leading, spacing: .x4) {
            Assets.credentialUpdate.swiftUIImage
              .frame(width: .x14, height: .x14, alignment: .leading)
              .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: .x1) {
              Text(title)
                .font(.custom.bodyEmphasized)
                .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
                .accessibilityAddTraits(.isHeader)

              Text(bodyText)
                .font(.custom.body)
                .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
                .multilineTextAlignment(.leading)
            }
          }
          .padding(.horizontal, .x4)
          .padding(.vertical, .x5)
        }

        if let primaryButtonTitle, let primaryAction {
          SectionView(minHeight: nil, hasContentPadding: false) {
            Button(action: primaryAction) {
              Text(primaryButtonTitle)
                .font(.custom.body)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, .x4)
                .frame(minHeight: 51)
            }
            .tint(.blue)
            .accessibilityIdentifier(primaryButtonAccessibilityIdentifier)
          }
        }

        if let issuerDisplay {
          VStack(alignment: .leading, spacing: 0) {
            Text(L10n.tkActivityActivityDetailIssuerTitle)
              .font(.custom.headline)
              .foregroundStyle(ThemingAssets.Label.sectionHeader.swiftUIColor)
              .padding(.leading, .x8)
              .padding(.trailing, .x4)
              .padding(.vertical, .x1)
              .accessibilityAddTraits(.isHeader)

            SectionView(minHeight: nil) {
              HStack(alignment: .center, spacing: .x3) {
                NormalizedLogoCircular(issuerDisplay.image)
                  .controlSize(.mini)

                Text(issuerDisplay.name ?? L10n.tkErrorNotregisteredTitle)
                  .font(.custom.body)
                  .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
                  .multilineTextAlignment(.leading)
              }
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.horizontal, .x4)
              .padding(.vertical, .x2)
            }
          }
        }
      }
      .padding(.top, .x4)
      .frame(maxHeight: .infinity, alignment: .top)
      .landscapeMaxWidth()
      .applyScrollViewIfNeeded()
    }

    @ViewBuilder
    private func errorNotificationView() -> some View {
      if isErrorPresented {
        Notification(
          systemImageName: "exclamationmark.triangle",
          imageColor: ThemingAssets.Brand.Core.swissRed.swiftUIColor,
          title: errorTitle,
          titleColor: ThemingAssets.Brand.Core.swissRed.swiftUIColor,
          content: errorMessage,
          contentColor: ThemingAssets.Label.secondary.swiftUIColor,
          closeAction: closeErrorAction,
          background: ThemingAssets.Brand.Bright.swissRed.swiftUIColor,
          closeButtonStyle: .secondary)
          .padding(.horizontal, .x4)
          .padding(.top, .x4)
          .accessibilityElement(children: .combine)
          .accessibilityIdentifier(errorAccessibilityIdentifier)
          .transition(.move(edge: .top).combined(with: .opacity))
      }
    }
  }
}
