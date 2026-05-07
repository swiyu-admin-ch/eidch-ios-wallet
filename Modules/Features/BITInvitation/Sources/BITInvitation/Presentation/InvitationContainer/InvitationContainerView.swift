import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

struct InvitationContainerView: View {

  // MARK: Lifecycle

  init(tab: InvitationTab = .scan) {
    selectedTab = tab
  }

  // MARK: Internal

  var body: some View {
    content()
      .onAppear {
        announceSelectedTab()
      }
      .onChange(of: selectedTab) { _, _ in
        announceSelectedTab()
      }
      .toolbar { toolbarContent }
      .navigationBarBackButtonHidden()
      .navigationBarTitleDisplayMode(.inline)
      .accessibilityElement(children: .contain)
  }

  // MARK: Private

  @State private var selectedTab: InvitationTab

  @Environment(\.navigator) private var navigator: Navigator

  @Orientation private var orientation
  @Injected(\.isProximityEnabled) private var isProximityEnabled: Bool

  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .primaryAction) {
      Button(action: { navigator.dismiss() }, label: {
        Assets.close.swiftUIImage
      })
      .colorScheme(.light)
      .accessibilityLabel(L10n.tkQrscannerButtonCloseAlt)
      .contentShape(.accessibility, Circle().inset(by: .x1))
    }
  }

  private func content() -> some View {
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
    .safeAreaInset(edge: .bottom) {
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
      }
    }
  }

  private func announceSelectedTab() {
    let announcement = selectedTab == .scan ? L10n.tkQrscannerScanningTitle : L10n.tkProximityEngagementTitle
    UIAccessibility.post(notification: .screenChanged, argument: announcement)
  }

}
