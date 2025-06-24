import BITCredentialShared
import BITTheming
import Foundation
import SwiftUI

public struct ClaimListView: View {

  // MARK: Lifecycle

  public init(_ claims: [CredentialClaim]) {
    self.claims = claims
  }

  // MARK: Public

  public var body: some View {
    ForEach(Array(zip(claims.indices, claims)), id: \.0) { index, claim in
      VStack(alignment: .leading, spacing: 0) {
        if let imageData = claim.imageData {
          KeyValueCustomCell(key: claim.preferredDisplay?.name ?? claim.key) {
            Image(data: imageData)?
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(maxWidth: Defaults.maxImageWidth, maxHeight: Defaults.maxImageHeight, alignment: .leading)
          }
          .padding(.trailing, .x6)
        } else {
          KeyValueCell(key: claim.preferredDisplay?.name ?? claim.key, value: claim.value)
            .padding(.trailing, .x6)
        }

        if index != claims.count - 1 {
          Divider()
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.leading, .x6)
    }
  }

  // MARK: Private

  private enum Defaults {
    static let maxImageHeight: CGFloat = 120
    static let maxImageWidth: CGFloat = 120
  }

  private var claims: [CredentialClaim]

}
