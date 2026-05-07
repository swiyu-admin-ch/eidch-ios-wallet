import BITL10n
import BITTheming
import SwiftUI

// MARK: - HomeActionButtons

struct HomeActionButtons: View {

  // MARK: Lifecycle

  init(onScanAction: @escaping () -> Void, onQRCodeAction: @escaping () -> Void) {
    self.onScanAction = onScanAction
    self.onQRCodeAction = onQRCodeAction
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

  private let shadowOpacity: CGFloat = 0.1
  private let iconSize: CGFloat = 20
  private let landscapeIconSize: CGFloat = 24
  private let landscapeButtonSize: CGFloat = 64

  @Orientation private var orientation

  private let onScanAction: () -> Void
  private let onQRCodeAction: () -> Void

  @ViewBuilder
  private var content: some View {
    if orientation.isLandscape {
      VStack(spacing: .x2) {
        scanIconButton()
        qrCodeIconButton()
      }
    } else {
      HStack(spacing: .x3) {
        scanButton()
        qrCodeButton()
      }
    }
  }

  private func scanButton() -> some View {
    Button(action: onScanAction) {
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

  private func scanIconButton() -> some View {
    Button(action: onScanAction) {
      ThemingAssets.scanIcon.swiftUIImage
        .renderingMode(.template)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: landscapeIconSize, height: landscapeIconSize)
        .foregroundColor(ThemingAssets.Brand.Core.white.swiftUIColor)
        .frame(width: landscapeButtonSize, height: landscapeButtonSize)
    }
    .buttonBackground(tint: ThemingAssets.Brand.Core.navyBlue.swiftUIColor)
    .contentShape(.accessibility, .capsule)
    .accessibilityLabel(L10n.tkGlobalScanPrimarybuttonAlt)
  }

  private func qrCodeButton() -> some View {
    Button(action: onQRCodeAction) {
      ThemingAssets.qrCodeIcon.swiftUIImage
        .renderingMode(.template)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: iconSize, height: iconSize)
        .foregroundColor(ThemingAssets.Brand.Core.navyBlue.swiftUIColor)
        .frame(width: .x14, height: .x14)
    }
    .buttonBackground(tint: ThemingAssets.Brand.Core.navyBlueLabel.swiftUIColor)
    .contentShape(.accessibility, .capsule)
    .accessibilityLabel(L10n.tkProximityEngagementTitle)
  }

  private func qrCodeIconButton() -> some View {
    Button(action: onQRCodeAction) {
      ThemingAssets.qrCodeIcon.swiftUIImage
        .renderingMode(.template)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: landscapeIconSize, height: landscapeIconSize)
        .foregroundColor(ThemingAssets.Brand.Core.navyBlue.swiftUIColor)
        .frame(width: landscapeButtonSize, height: landscapeButtonSize)
    }
    .buttonBackground(tint: ThemingAssets.Brand.Core.navyBlueLabel.swiftUIColor)
    .contentShape(.accessibility, .capsule)
    .accessibilityLabel(L10n.tkProximityEngagementTitle)
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

// MARK: - Preview

#Preview {
  HomeActionButtons(
    onScanAction: {},
    onQRCodeAction: {})
    .padding()
}
