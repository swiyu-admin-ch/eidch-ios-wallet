import SwiftUI

// MARK: - AdaptiveButtonStack

public struct AdaptiveButtonStack<PrimaryContent: View, SecondaryContent: View>: View {

  // MARK: Lifecycle

  public init(
    spacing: CGFloat = .x4,
    forceVertical: Bool = false,
    @ViewBuilder primary: @escaping () -> PrimaryContent,
    @ViewBuilder secondary: @escaping () -> SecondaryContent)
  {
    self.spacing = spacing
    self.forceVertical = forceVertical
    self.primary = primary
    self.secondary = secondary
  }

  // MARK: Public

  public var body: some View {
    AdaptiveButtonsLayout(
      spacing: spacing,
      forceVertical: forceVertical || sizeCategory.isAccessibilityCategory)
    {
      primary()
      secondary()
    }
  }

  // MARK: Private

  @Environment(\.sizeCategory) private var sizeCategory

  private let spacing: CGFloat
  private let forceVertical: Bool
  private let primary: () -> PrimaryContent
  private let secondary: () -> SecondaryContent

}

// MARK: - AdaptiveButtonsLayout

struct AdaptiveButtonsLayout: Layout {
  var spacing: CGFloat
  var forceVertical = false

  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ())
    -> CGSize
  {
    let primaryButtonSize = subviews.first?.sizeThatFits(.unspecified) ?? .zero
    let secondaryButtonSize = subviews.last?.sizeThatFits(.unspecified) ?? .zero
    let maxButtonWidth = max(primaryButtonSize.width, secondaryButtonSize.width)
    let availableWidth = proposal.width ?? .zero

    let fitsHorizontal = maxButtonWidth * 2 + spacing < availableWidth

    if fitsHorizontal && !forceVertical {
      let height = max(primaryButtonSize.height, secondaryButtonSize.height)
      return CGSize(width: availableWidth, height: height)
    }
    let height = primaryButtonSize.height + spacing + secondaryButtonSize.height
    return CGSize(width: availableWidth, height: height)
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ())
  {
    let primaryButton = subviews.first
    let secondaryButton = subviews.last
    let primaryButtonSize = primaryButton?.sizeThatFits(.unspecified) ?? .zero
    let secondaryButtonSize = secondaryButton?.sizeThatFits(.unspecified) ?? .zero
    let maxButtonWidth = max(primaryButtonSize.width, secondaryButtonSize.width)

    let fitsHorizontal = maxButtonWidth * 2 + spacing < bounds.width

    if fitsHorizontal && !forceVertical {
      let buttonWidth = (bounds.width - spacing) / 2
      primaryButton?.place(
        at: CGPoint(x: bounds.maxX, y: bounds.midY),
        anchor: .trailing,
        proposal: ProposedViewSize(width: buttonWidth, height: primaryButtonSize.height))
      secondaryButton?.place(
        at: CGPoint(x: bounds.minX, y: bounds.midY),
        anchor: .leading,
        proposal: ProposedViewSize(width: buttonWidth, height: secondaryButtonSize.height))
    } else {
      primaryButton?.place(
        at: CGPoint(x: bounds.midX, y: bounds.minY),
        anchor: .top,
        proposal: ProposedViewSize(width: bounds.width, height: primaryButtonSize.height))
      secondaryButton?.place(
        at: CGPoint(x: bounds.midX, y: bounds.maxY),
        anchor: .bottom,
        proposal: ProposedViewSize(width: bounds.width, height: secondaryButtonSize.height))
    }
  }
}
