import BITTheming
import SwiftUI

// MARK: - ActivityCell

public struct ActivityCell: View {

  // MARK: Lifecycle

  public init(
    _ viewModel: ActivityCellViewModel,
    configuration: Configuration = .default,
    onTap: (() -> Void)? = nil)
  {
    self.viewModel = viewModel
    self.configuration = configuration
    self.onTap = onTap
  }

  // MARK: Public

  public enum Configuration {
    case `default`
    case compact
  }

  public var body: some View {
    if let onTap {
      Button(action: { onTap() }) {
        content
      }
    } else {
      content
    }
  }

  // MARK: Private

  @ScaledMetric(relativeTo: .body) private var trailingIconSize: CGFloat = 11
  @ScaledMetric(relativeTo: .body) private var leadingIconSize: CGFloat = 30

  private let viewModel: ActivityCellViewModel
  private let configuration: Configuration
  private let onTap: (() -> Void)?

  @ViewBuilder
  private var content: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        leadingIcon
          .padding(.trailing, .x3)
        texts
        Spacer(minLength: .x2)
        if onTap != nil {
          trailingIcon
        }
      }
      .accessibilityElement(children: .combine)
    }
  }

  @ViewBuilder
  private var leadingIcon: some View {
    viewModel.icon
      .resizable()
      .scaledToFit()
      .frame(width: leadingIconSize, height: leadingIconSize)
      .accessibilityHidden(true)
  }

  @ViewBuilder
  private var texts: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(viewModel.title)
        .multilineTextAlignment(.leading)
        .font(.custom.body)
        .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
      if configuration != .compact {
        Text(viewModel.subtitle)
          .multilineTextAlignment(.leading)
          .font(.custom.body)
          .foregroundColor(ThemingAssets.Label.secondary.swiftUIColor)
      }
      Text(viewModel.timeStamp)
        .multilineTextAlignment(.leading)
        .font(.custom.caption1)
        .foregroundColor(ThemingAssets.Label.secondary.swiftUIColor)
        .padding(.top, .x1)
        .accessibilityLabel(viewModel.accessibleTimeStamp)
    }
  }

  @ViewBuilder
  private var trailingIcon: some View {
    ThemingAssets.chevronRight.swiftUIImage
      .resizable()
      .scaledToFit()
      .foregroundColor(ThemingAssets.Label.secondary.swiftUIColor)
      .frame(width: trailingIconSize, height: trailingIconSize)
      .accessibilityHidden(true)
  }
}

#if DEBUG
#Preview {
  VStack {
    ActivityCell(ActivityCellViewModel(activity: .Mock.issueTrusted))
    ActivityCell(ActivityCellViewModel(activity: .Mock.presentationAcceptedTrusted))
    ActivityCell(ActivityCellViewModel(activity: .Mock.presentationDeclinedUntrusted))
  }
}
#endif
