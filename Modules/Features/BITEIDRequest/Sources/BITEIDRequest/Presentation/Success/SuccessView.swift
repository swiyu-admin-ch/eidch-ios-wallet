import BITTheming
import Factory
import Foundation
import NavigatorUI
import SwiftUI

struct SuccessView: View {
  var body: some View {
    VStack {
      Image(systemName: "checkmark.circle")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 80)
        .foregroundStyle(ThemingAssets.Brand.Core.firGreen.swiftUIColor)
      Button("Back home") {
        coordinator.cleanup()
        navigator.dismiss()
      }
    }
  }

  @Injected(\.eidRequestFlowCoordinator) private var coordinator
  @Environment(\.navigator) private var navigator
}
