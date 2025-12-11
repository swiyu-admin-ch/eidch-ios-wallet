import BITTheming
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
        navigator.dismiss()
      }
    }
  }

  @Environment(\.navigator) private var navigator
}
