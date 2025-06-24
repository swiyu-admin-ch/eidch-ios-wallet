import BITCredentialShared
import BITL10n
import BITOpenID
import BITTheming
import SwiftUI

// MARK: - CredentialStatusBadge

public struct CredentialStatusBadge: View {

  // MARK: Lifecycle

  public init(_ viewModel: CredentialViewModel) {
    self.viewModel = viewModel
  }

  // MARK: Public

  public var body: some View {
    VStack {
      Badge {
        Label(
          title: {
            Text(viewModel.statusText)
          },
          icon: {
            if !sizeCategory.isAccessibilityCategory {
              viewModel.statusImage
                .resizable()
                .scaledToFit()
                .frame(width: Defaults.imageWidth, height: Defaults.imageHeight)
            }
          })
      }
      .accessibilityLabel(viewModel.statusTextAlt)
      .badgeStyle(AnyBadgeStyle(style: viewModel.statusBadgeStyle))
    }
  }

  // MARK: Private

  private enum Defaults {
    static let imageWidth: CGFloat = 14
    static let imageHeight: CGFloat = 18
  }

  @Environment(\.sizeCategory) private var sizeCategory

  private let viewModel: CredentialViewModel

}

#if DEBUG
#Preview {
  VStack {
    CredentialStatusBadge(CredentialViewModel(credential: .Mock.sample, credentialDisplay: Credential.Mock.sample.displays[0]))
  }.background(.blue)
}
#endif
