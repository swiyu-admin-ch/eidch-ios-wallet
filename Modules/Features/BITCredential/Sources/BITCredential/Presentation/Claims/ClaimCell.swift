import BITCredentialShared
import BITTheming
import Foundation
import SwiftUI

// MARK: - ClaimCell

public struct ClaimCell: View {

  // MARK: Lifecycle

  public init(_ claim: CredentialClaim, showDivider: Bool) {
    viewModel = CredentialClaimViewModel(claim)
    self.showDivider = showDivider
  }

  // MARK: Public

  public var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      if let imageData = viewModel.imageData {
        KeyValueCustomCell(key: viewModel.nameLabel) {
          Image(data: imageData)?
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: Defaults.maxImageWidth, minHeight: Defaults.minHeight, maxHeight: Defaults.maxImageHeight, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, .x6)
      } else {
        KeyValueCell(key: viewModel.nameLabel, value: viewModel.valueLabel)
          .padding(.trailing, .x6)
          .frame(minHeight: Defaults.minHeight)
          .frame(maxWidth: .infinity, alignment: .leading)
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
  private let showDivider: Bool

}
