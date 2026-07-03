import BITCredentialShared
import BITTheming
import Foundation
import SwiftUI

// MARK: - ChildClusterView

public struct ChildClusterView: View {

  // MARK: Lifecycle

  public init(_ cluster: CredentialClaimCluster, isSensitive: Bool, showLastDivider: Bool) {
    self.cluster = cluster
    self.isSensitive = isSensitive
    self.showLastDivider = showLastDivider
  }

  // MARK: Public

  public var body: some View {
    LazyVStack(alignment: .leading, spacing: 0) {
      let items = cluster.items
      ForEach(items.indices, id: \.self) { index in
        let item = items[index]
        if let claim = item as? CredentialClaim {
          let isPreviousItemCluster = index > 0 && items[index - 1] is CredentialClaimCluster
          ClaimCell(
            claim,
            isSensitive: isSensitive,
            showDivider: index < items.count - 1 || showLastDivider,
            showClaimKey: !cluster.isSimpleArray)
            .padding(.top, isPreviousItemCluster ? .x4 : 0)
        } else if let childCluster = item as? CredentialClaimCluster {
          if let title = childCluster.displays.findDisplayWithFallback()?.name {
            Text(title)
              .font(.custom.headline)
              .padding(.top, .x6)
              .padding(.bottom, .x2)
              .accessibilityAddTraits(.isHeader)
          }
          Self(
            childCluster,
            isSensitive: isSensitive || cluster.isSensitive,
            showLastDivider: index < items.count - 1 || showLastDivider)
            .padding(.top, index > 0 && cluster.displays.findDisplayWithFallback() == nil ? .x6 : 0)
        }
      }
    }
    .accessibilityElement(children: .contain)
  }

  // MARK: Private

  private let cluster: CredentialClaimCluster
  private let showLastDivider: Bool
  private let isSensitive: Bool
}

#if DEBUG
#Preview {
  ZStack {
    ChildClusterView(.Mock.singleLevel, isSensitive: false, showLastDivider: false)
      .padding()
  }
  .frame(maxHeight: .infinity)
  .background(ThemingAssets.Background.secondary.swiftUIColor)
}
#endif
