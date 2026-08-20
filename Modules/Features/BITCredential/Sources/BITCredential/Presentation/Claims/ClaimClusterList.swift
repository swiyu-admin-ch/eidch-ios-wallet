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
        sectionView(cluster)
      }
    }
  }

  // MARK: Private

  private var clusters: [CredentialClaimCluster]

  private func sectionView(_ cluster: CredentialClaimCluster) -> some View {
    SectionView(title: cluster.displays.findDisplayWithFallback()?.name) {
      let items = cluster.items
      ForEach(items.indices, id: \.self) { index in
        let item = items[index]
        VStack(alignment: .leading, spacing: 0) {
          if let claim = item as? CredentialClaim {
            let isPreviousItemCluster = index > 0 && items[index - 1] is CredentialClaimCluster
            ClaimCell(
              claim,
              isSensitive: cluster.isSensitive,
              showDivider: index < items.count - 1,
              showClaimKey: !cluster.isSimpleArray)
              .padding(.top, isPreviousItemCluster ? .x4 : 0)
          } else if let childCluster = item as? CredentialClaimCluster {
            childClusterView(
              childCluster,
              isSensitive: cluster.isSensitive,
              isFirstInCluster: index == 0,
              showLastDivider: index < items.count - 1)
          }
        }
        .padding(.leading, .x6)
      }
    }
  }

  @ViewBuilder
  private func childClusterView(
    _ cluster: CredentialClaimCluster,
    isSensitive: Bool,
    isFirstInCluster: Bool,
    showLastDivider: Bool)
    -> some View
  {
    if let title = cluster.displays.findDisplayWithFallback()?.name {
      Text(title)
        .font(.custom.title3Emphasized)
        .padding(.vertical, .x2)
        .accessibilityAddTraits(.isHeader)
    }
    ChildClusterView(cluster, isSensitive: isSensitive, showLastDivider: showLastDivider)
      .padding(.top, !isFirstInCluster && cluster.displays.findDisplayWithFallback() == nil ? .x8 : 0)
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
