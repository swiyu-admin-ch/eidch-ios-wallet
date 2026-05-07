import BITCore
import BITL10n
import BITTheming
import SwiftUI

// MARK: - InvitationContainerCapsule

struct InvitationContainerCapsule: View {

  // MARK: Internal

  let selectedTab: InvitationTab
  let selectTab: (InvitationTab) -> Void

  var body: some View {
    if #available(iOS 26, *) {
      GlassEffectContainer(spacing: .x2) {
        tabBarContent
      }
      .padding(.x2)
      .background {
        RoundedRectangle(cornerRadius: .x12)
          .glassEffect(.regular, in: .rect(cornerRadius: .x12))
      }
      .padding(.bottom, .x4)
    } else {
      tabBarContent
        .padding(.x2)
        .background {
          RoundedRectangle(cornerRadius: .x12)
            .fill(.ultraThinMaterial)
        }
        .padding(.bottom, .x4)
    }
  }

  // MARK: Private

  @Namespace private var selectionAnimation

  private var tabBarContent: some View {
    HStack(spacing: .x2) {
      tabButton(
        title: L10n.tkGlobalScanPrimarybutton,
        icon: ThemingAssets.scanIcon.swiftUIImage,
        isSelected: selectedTab == .scan)
      {
        selectTab(.scan)
      }

      tabButton(
        title: L10n.tkProximityEngagementTab,
        icon: ThemingAssets.qrCodeIcon.swiftUIImage,
        isSelected: selectedTab == .proximityEngagement)
      {
        selectTab(.proximityEngagement)
      }
    }
  }

  private func tabButton(title: String, icon: Image, isSelected: Bool, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      HStack(spacing: .x2) {
        icon
          .accessibilityHidden(true)
        Text(title)
      }
      .font(.custom.subheadline)
      .foregroundStyle(ThemingAssets.Brand.Core.navyBlue.swiftUIColor)
      .padding(.horizontal, .defaultHorizontal)
      .padding(.vertical, .defaultVertical)
      .background {
        if isSelected {
          Capsule()
            .fill(ThemingAssets.Brand.Core.white.swiftUIColor)
            .shadow(color: ThemingAssets.Brand.Core.black.swiftUIColor.opacity(0.1), radius: 8, x: 0, y: 0)
            .matchedGeometryEffect(id: "invitationTabSelection", in: selectionAnimation)
        }
      }
    }
    .buttonStyle(.plain)
    .accessibilityLabel(title)
    .accessibilityAddTraits(isSelected ? [.isSelected] : [])
  }
}

#if DEBUG
#Preview {
  InvitationContainerCapsule(selectedTab: .scan) { _ in

  }
}
#endif
