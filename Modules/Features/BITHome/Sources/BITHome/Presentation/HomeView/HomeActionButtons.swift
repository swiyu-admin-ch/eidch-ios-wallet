import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - HomeActionButtons

struct HomeActionButtons: View {

  // MARK: Lifecycle

  init(axis: Axis = .horizontal) {
    self.axis = axis
  }

  // MARK: Internal

  var body: some View {
    if #available(iOS 26, *) {
      GlassEffectContainer(spacing: .zero) {
        content
      }
      .padding(.x2)
      .glassEffect(.regular, in: .capsule(style: .continuous))
    } else {
      content
        .padding(.x2)
        .background(
          Capsule()
            .fill(ThemingAssets.Brand.Core.white.swiftUIColor)
            .shadow(color: ThemingAssets.Brand.Core.black.swiftUIColor.opacity(shadowOpacity), radius: .x2, x: 0, y: 2))
    }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator
  @Environment(\.sizeCategory) private var sizeCategory

  @Injected(\.isProximityEnabled) private var isProximityEnabled: Bool

  private let axis: Axis

  private let shadowOpacity: CGFloat = 0.1
  private let iconSize: CGFloat = 20
  private let verticalIconSize: CGFloat = 24
  private let verticalButtonSize: CGFloat = 64

  @ViewBuilder
  private var content: some View {
    if axis == .vertical {
      VStack(spacing: .x2) { iconOnlyButtons }
    } else if sizeCategory.isAccessibilityCategory {
      HStack(spacing: .x3) { iconOnlyButtons }
    } else {
      HStack(spacing: .x3) { labeledButtons }
    }
  }

  @ViewBuilder
  private var labeledButtons: some View {
    scanButton
    if isProximityEnabled {
      qrCodeButton
    }
  }

  @ViewBuilder
  private var iconOnlyButtons: some View {
    scanIconButton
    if isProximityEnabled {
      qrCodeIconButton
    }
  }

  private var scanButton: some View {
    Button(action: { navigator.navigate(to: HomeDestinations.external(.invitation(.scan))) }) {
      HStack(spacing: .x2) {
        ThemingAssets.scanIcon.swiftUIImage
          .renderingMode(.template)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: iconSize, height: iconSize)
        Text(L10n.tkGlobalScanPrimarybutton)
          .font(.custom.body)
          .fontWeight(.semibold)
      }
      .foregroundColor(ThemingAssets.Brand.Core.white.swiftUIColor)
      .padding(.horizontal, .x6)
      .padding(.vertical, .x4)
      .buttonBackground(tint: ThemingAssets.Brand.Core.navyBlue.swiftUIColor)
    }
    .contentShape(.accessibility, .capsule)
    .accessibilityLabel(L10n.tkGlobalScanPrimarybuttonAlt)
  }

  private var scanIconButton: some View {
    Button(action: { navigator.navigate(to: HomeDestinations.external(.invitation(.scan))) }) {
      ThemingAssets.scanIcon.swiftUIImage
        .renderingMode(.template)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: verticalIconSize, height: verticalIconSize)
        .foregroundColor(ThemingAssets.Brand.Core.white.swiftUIColor)
        .frame(width: verticalButtonSize, height: verticalButtonSize)
    }
    .buttonBackground(tint: ThemingAssets.Brand.Core.navyBlue.swiftUIColor)
    .contentShape(.accessibility, .capsule)
    .accessibilityLabel(L10n.tkGlobalScanPrimarybuttonAlt)
  }

  private var qrCodeButton: some View {
    Button(action: { navigator.navigate(to: HomeDestinations.external(.invitation(.proximityEngagement))) }) {
      ThemingAssets.qrCodeIcon.swiftUIImage
        .renderingMode(.template)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: iconSize, height: iconSize)
        .foregroundColor(ThemingAssets.Fills.primary.swiftUIColor)
        .frame(width: .x14, height: .x14)
    }
    .buttonBackground(tint: ThemingAssets.Background.Button.secondary.swiftUIColor)
    .contentShape(.accessibility, .capsule)
    .accessibilityLabel(L10n.tkProximityEngagementTitleAlt)
  }

  private var qrCodeIconButton: some View {
    Button(action: { navigator.navigate(to: HomeDestinations.external(.invitation(.proximityEngagement))) }) {
      ThemingAssets.qrCodeIcon.swiftUIImage
        .renderingMode(.template)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: verticalIconSize, height: verticalIconSize)
        .foregroundColor(ThemingAssets.Fills.primary.swiftUIColor)
        .frame(width: verticalButtonSize, height: verticalButtonSize)
    }
    .buttonBackground(tint: ThemingAssets.Background.Button.secondary.swiftUIColor)
    .contentShape(.accessibility, .capsule)
    .accessibilityLabel(L10n.tkProximityEngagementTitleAlt)
  }
}

extension View {

  @ViewBuilder
  fileprivate func buttonBackground(tint: Color) -> some View {
    if #available(iOS 26, *) {
      glassEffect(.regular.tint(tint))
    } else {
      background(
        Capsule()
          .fill(tint))
    }
  }
}
