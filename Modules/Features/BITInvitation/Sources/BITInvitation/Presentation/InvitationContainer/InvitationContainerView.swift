import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - InvitationContainerView

struct InvitationContainerView: View {

  // MARK: Lifecycle

  init(tab: InvitationTab = .scan) {
    selectedTab = tab
  }

  // MARK: Internal

  var body: some View {
    content
      .onChange(of: selectedTab, initial: true, announceSelectedTab)
      .toolbar { toolbarContent }
      .navigationBarBackButtonHidden()
      .navigationBarTitleDisplayMode(.inline)
      .accessibilityElement(children: .contain)
  }

  // MARK: Private

  @State private var selectedTab: InvitationTab
  @State private var tabBarHeight: CGFloat = 0

  @Environment(\.navigator) private var navigator: Navigator

  @Orientation private var orientation
  @Injected(\.isProximityEnabled) private var isProximityEnabled: Bool
  @Injected(\.accessibilityFeedback) private var accessibilityFeedback: CameraAccessibilityFeedbackProtocol

  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .primaryAction) {
      Button(action: { navigator.dismiss() }, label: {
        Image(systemName: "xmark")
      })
      .accessibilityLabel(L10n.tkGlobalClose)
      .contentShape(.accessibility, Circle().inset(by: .x1))
    }
  }

  private var content: some View {
    ZStack {
      switch selectedTab {
      case .scan:
        CameraView()
          .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
      case .proximityEngagement:
        ProximityEngagementView()
          .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
      }
    }
    .overlay(alignment: .bottom) {
      if isProximityEnabled {
        HStack {
          if orientation.isLandscape {
            Spacer(minLength: 0)
          }
          InvitationContainerCapsule(
            selectedTab: selectedTab,
            selectTab: { tab in
              withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
              }
            })
        }
        .readSize { tabBarHeight = $0.height }
      }
    }
    .environment(\.invitationTabBarInset, tabBarHeight)
  }

  private func announceSelectedTab() {
    if selectedTab != .scan {
      accessibilityFeedback.announceCameraDidStopRunning()
    }

    let announcement = selectedTab == .scan ? L10n.tkQrscannerScanningTitle : L10n.tkProximityEngagementTitle
    UIAccessibility.post(notification: .screenChanged, argument: announcement)
  }

}

// MARK: - Environment

extension EnvironmentValues {
  @Entry var invitationTabBarInset: CGFloat = 0
}
