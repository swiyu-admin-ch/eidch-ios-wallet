import BITCredentialShared
import BITL10n
import BITTheming
import Foundation
import SwiftUI

// MARK: - ClaimCell

public struct ClaimCell: View {

  // MARK: Lifecycle

  public init(_ claim: CredentialClaim, isSensitive: Bool, showDivider: Bool, showClaimKey: Bool) {
    viewModel = CredentialClaimViewModel(claim)
    self.isSensitive = isSensitive
    self.showDivider = showDivider
    self.showClaimKey = showClaimKey
  }

  // MARK: Public

  public var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      if let imageData = viewModel.imageData {
        KeyValueCustomCell(key: viewModel.nameLabel, showClaimKey: showClaimKey, trailingContent: {
          trailingView
        }) {
          Image(data: imageData)?
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: Defaults.maxImageWidth, minHeight: Defaults.minHeight, maxHeight: Defaults.maxImageHeight, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, .x6)
      } else {
        KeyValueCell(key: viewModel.nameLabel, value: viewModel.valueLabel, showClaimKey: showClaimKey) {
          trailingView
        }.padding(.trailing, .x6)
          .frame(minHeight: Defaults.minHeight)
          .frame(maxWidth: .infinity, alignment: .leading)
          .accessibilityLabel(viewModel.accessibilityValueLabel)
      }
      if showDivider {
        Divider()
      }
    }
  }

  // MARK: Private

  private enum Defaults {
    static let maxImageHeight: CGFloat = 120
    static let maxImageWidth: CGFloat = 120
    static let minHeight: CGFloat = 60
  }

  private let viewModel: CredentialClaimViewModel
  private let isSensitive: Bool
  private let showDivider: Bool
  private let showClaimKey: Bool

  @ViewBuilder
  private var trailingView: some View {
    if isSensitive || viewModel.isSensitive {
      Badge(label: L10n.tkGlobalSensitiveData)
        .badgeStyle(.sensitive)
    } else {
      EmptyView()
    }
  }

}
