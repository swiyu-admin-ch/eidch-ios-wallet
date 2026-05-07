import BITTheming
import SwiftUI

struct PrivacyOverlayView: View {

  var body: some View {
    VStack {
      Asset.logoExtended.swiftUIImage
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(maxWidth: 270)
        .accessibilityHidden(true)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(ThemingAssets.Background.primary.swiftUIColor)
  }
}
