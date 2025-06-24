import BITTheming
import Foundation
import SwiftUI

// MARK: - DocumentSelectionCell

struct DocumentSelectionCell: View {

  var image: Image
  var name: String
  var didSelect: () -> Void

  var body: some View {
    ProgrammaticNavigationCell(didSelect: didSelect) {
      HStack(spacing: .x4) {
        image
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 80, height: 69)
          .accessibilityHidden(true)

        Text(name)
          .font(.custom.body)
          .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(name)
    .listRowBackground(ThemingAssets.background.swiftUIColor)
  }
}
