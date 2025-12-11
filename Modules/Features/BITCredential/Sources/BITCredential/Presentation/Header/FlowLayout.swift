import SwiftUI

public struct FlowLayout: Layout {

  // MARK: Lifecycle

  public init(verticalSpacing: CGFloat = 0, horizontalSpacing: CGFloat = 0) {
    self.verticalSpacing = verticalSpacing
    self.horizontalSpacing = horizontalSpacing
  }

  // MARK: Public

  public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
    if let width = proposal.width, width > 0 {
      let height = calculateHeight(boundsWidth: width, proposal: proposal, subviews: subviews)
      return CGSize(width: width, height: height)
    }

    return proposal.replacingUnspecifiedDimensions()
  }

  public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
    var x: CGFloat = 0
    var y: CGFloat = 0
    var rowHeight: CGFloat = 0

    for subview in subviews {
      let viewDimensions = subview.dimensions(in: proposal)
      if x > 0, x + viewDimensions.width > bounds.width {
        y += rowHeight + verticalSpacing
        x = 0
        rowHeight = 0
      }
      rowHeight = max(rowHeight, viewDimensions.height)

      var point = CGPoint(x: bounds.minX + x, y: bounds.minY + y)
      point.x += viewDimensions.width / 2
      point.y += viewDimensions.height / 2

      let widthProposal = min(proposal.width ?? .infinity, viewDimensions.width)
      subview.place(at: point, anchor: .center, proposal: ProposedViewSize(width: widthProposal, height: nil))

      x += viewDimensions.width + horizontalSpacing
    }
  }

  // MARK: Private

  private let verticalSpacing: CGFloat
  private let horizontalSpacing: CGFloat

  private func calculateHeight(boundsWidth: CGFloat, proposal: ProposedViewSize, subviews: Subviews) -> CGFloat {
    var x: CGFloat = 0
    var y: CGFloat = 0
    var rowHeight: CGFloat = 0

    for subview in subviews {
      let viewDimensions = subview.dimensions(in: proposal)
      if x > 0, x + viewDimensions.width > boundsWidth {
        y += rowHeight + verticalSpacing
        x = 0
        rowHeight = 0
      }
      rowHeight = max(rowHeight, viewDimensions.height)
      x += viewDimensions.width + horizontalSpacing
    }

    return y + rowHeight
  }
}
