import BITTheming
import SwiftUI

struct NFCScanResultListViewCell: View {

  // MARK: Lifecycle

  init(entry: NFCScanResultViewModel.NFCScanResultEntryType) {
    self.entry = entry
  }

  // MARK: Internal

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      switch entry {
      case .image(let key, let value):
        KeyValueCustomCell(key: key) {
          Image(data: value)?
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: Self.maxImageWidth, minHeight: Self.minHeight, maxHeight: Self.maxImageHeight, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, .x4)
      case .text(let key, let value):
        KeyValueCell(key: key, value: value)
          .padding(.trailing, .x4)
          .frame(minHeight: Self.minHeight)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }

  // MARK: Private

  private static let minHeight: CGFloat = 60
  private static let maxImageWidth: CGFloat = 120
  private static let maxImageHeight: CGFloat = 120

  private let entry: NFCScanResultViewModel.NFCScanResultEntryType
}
