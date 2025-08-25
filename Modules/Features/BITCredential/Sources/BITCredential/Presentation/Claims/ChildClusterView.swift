import BITCredentialShared
import BITTheming
import Foundation
import SwiftUI

// MARK: - ChildClusterView

public struct ChildClusterView: View {

  // MARK: Lifecycle

  public init(_ cluster: CredentialClaimCluster, showLastDivider: Bool) {
    self.cluster = cluster
    self.showLastDivider = showLastDivider
  }

  // MARK: Public

  public var body: some View {
    LazyVStack(alignment: .leading, spacing: 0) {
      let items = cluster.items
      ForEach(Array(zip(items.indices, items)), id: \.0) { index, item in
        if let claim = item as? CredentialClaim {
          let isPreviousItemCluster = index > 0 && items[index - 1] is CredentialClaimCluster
          ClaimCell(claim, showDivider: index < items.count - 1 || showLastDivider)
            .padding(.top, isPreviousItemCluster ? .x4 : 0)
        } else if let childCluster = item as? CredentialClaimCluster {
          if let title = childCluster.preferredDisplay?.name {
            Text(title)
              .font(.custom.headline)
              .padding(.top, .x6)
              .padding(.bottom, .x2)
              .accessibilityAddTraits(.isHeader)
          }
          Self(childCluster, showLastDivider: index < items.count - 1 || showLastDivider)
            .padding(.top, index > 0 && cluster.preferredDisplay == nil ? .x6 : 0)
        }
      }
    }
    .accessibilityElement(children: .contain)
  }

  // MARK: Private

  private let cluster: CredentialClaimCluster
  private let showLastDivider: Bool
}

#if DEBUG
#Preview {
  ZStack {
    ChildClusterView(.Mock.singleLevel, showLastDivider: false)
      .padding()
  }
  .frame(maxHeight: .infinity)
  .background(ThemingAssets.Background.secondary.swiftUIColor)
}
#endif
