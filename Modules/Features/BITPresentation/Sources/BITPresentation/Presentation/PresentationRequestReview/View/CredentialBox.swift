import BITCredential
import BITCredentialShared
import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - CredentialBox

struct CredentialBox: View {

  // MARK: Lifecycle

  init(credential: Credential, compression: UICompressionStyle) {
    self.credential = credential
    self.compression = compression
  }

  // MARK: Internal

  var body: some View {
    VStack {
      if orientation.isPortrait {
        portraitContent()
      } else {
        landscapeContent()
      }
    }
    .padding(.vertical, orientation.isLandscape ? .x6 : compression.isCompressed ? .x8 : .x12)
    .padding(.horizontal, orientation.isLandscape ? .x6 : .x12)
    .background(Color(uiColor: .secondarySystemBackground))
    .clipShape(.rect(cornerRadius: .x5))
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
  }

  // MARK: Private

  @Orientation private var orientation

  private let compression: UICompressionStyle
  private let credential: Credential

  @ViewBuilder
  private func portraitContent() -> some View {
    HStack(spacing: .x4) {
      credentialCard(credential)
      credentialContent(credential, alignment: .leading)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  @ViewBuilder
  private func landscapeContent() -> some View {
    Spacer()
    VStack(spacing: .x3) {
      credentialCard(credential)
        .padding(.horizontal, .x25)
      credentialContent(credential, alignment: .center)
    }
    Spacer()
  }

  @ViewBuilder
  private func credentialCard(_ credential: Credential) -> some View {
    CredentialCard(credential)
      .controlSize(.small)
      .accessibilityHidden(true)
  }

  @ViewBuilder
  private func credentialContent(_ credential: Credential, alignment: HorizontalAlignment) -> some View {
    VStack(alignment: alignment) {
      Text(credential.preferredDisplay?.name ?? L10n.tkGlobalNotAssigned)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .multilineTextAlignment(alignment.textAlignment)

      if let summary = credential.preferredDisplay?.summary {
        Text(summary)
          .font(.custom.body)
          .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
          .multilineTextAlignment(alignment.textAlignment)
      }
    }
  }

}

extension HorizontalAlignment {
  fileprivate var textAlignment: TextAlignment {
    switch self {
    case .leading: .leading
    case .center: .center
    case .trailing: .trailing
    default: .leading
    }
  }
}
