import BITTheming
import Foundation
import SwiftUI

public struct ClaimListView: View {

  // MARK: Lifecycle

  public init(_ claims: [CredentialDetailBody.Claim]) {
    self.claims = claims
  }

  // MARK: Public

  public var body: some View {
    ForEach(Array(zip(claims.indices, claims)), id: \.0) { index, claim in
      VStack(alignment: .leading, spacing: 0) {
        if let imageData = claim.imageData {
          KeyValueCustomCell(key: claim.key) {
            Image(data: imageData)?
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(maxWidth: Defaults.maxImageWidth, maxHeight: Defaults.maxImageHeight)
          }
          .padding(.vertical, .x2)
        } else {
          KeyValueCell(key: claim.key, value: claim.value)
            .padding(.vertical, .x2)
        }

        if index != claims.count - 1 {
          Divider()
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  // MARK: Private

  private enum Defaults {
    static let maxImageHeight: CGFloat = 120
    static let maxImageWidth: CGFloat = 120
  }

  private var claims: [CredentialDetailBody.Claim]

}
