import BITCredentialShared
import BITTheming
import Foundation
import SwiftUI

// MARK: - ClaimClusterList

public struct ClaimClusterList: View {

  // MARK: Lifecycle

  public init(_ clusters: [CredentialClaimCluster]) {
    self.clusters = clusters
  }

  // MARK: Public

  public var body: some View {
    LazyVStack(spacing: .x6) {
      ForEach(clusters, id: \.id) { cluster in
        SectionView(title: cluster.preferredDisplay?.name) {
          let items = cluster.items
          ForEach(Array(zip(items.indices, items)), id: \.0) { index, item in
            VStack(alignment: .leading, spacing: 0) {
              if let claim = item as? CredentialClaim {
                let isPreviousItemCluster = index > 0 && items[index - 1] is CredentialClaimCluster
                ClaimCell(claim, showDivider: index < items.count - 1)
                  .padding(.top, isPreviousItemCluster ? .x4 : 0)
              } else if let childCluster = item as? CredentialClaimCluster {
                childClusterView(childCluster, isFirstInCluster: index == 0, showLastDivider: index < items.count - 1)
              }
            }
            .padding(.leading, .x6)
          }
        }
      }
    }
  }

  // MARK: Private

  private var clusters: [CredentialClaimCluster]

  @ViewBuilder
  private func childClusterView(_ cluster: CredentialClaimCluster, isFirstInCluster: Bool, showLastDivider: Bool) -> some View {
    if let title = cluster.preferredDisplay?.name {
      Text(title)
        .font(.custom.title3Emphasized)
        .padding(.vertical, .x2)
        .accessibilityAddTraits(.isHeader)
    }
    ChildClusterView(cluster, showLastDivider: showLastDivider)
      .padding(.top, !isFirstInCluster && cluster.preferredDisplay == nil ? .x8 : 0)
  }
}

#if DEBUG
#Preview {
  ZStack {
    ClaimClusterList(CredentialClaimCluster.Mock.arrayWithNested)
      .applyScrollViewIfNeeded()
  }
  .frame(maxHeight: .infinity)
  .background(ThemingAssets.Background.secondary.swiftUIColor)
}
#endif
