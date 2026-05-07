import BITTheming
import SwiftUI

struct ScanResultListView: View {

  // MARK: Lifecycle

  init(entries: [ScanResultEntryType], resizeImages: Bool = false) {
    self.entries = entries
    self.resizeImages = resizeImages
  }

  // MARK: Internal

  var body: some View {
    ForEach(entries, id: \.self) { entry in
      entryView(entry)
        .padding(.leading, .x4)
    }
  }

  // MARK: Private

  private static let minHeight: CGFloat = 60
  private static let maxImageWidth: CGFloat = 120
  private static let maxImageHeight: CGFloat = 120

  private let resizeImages: Bool
  private let entries: [ScanResultEntryType]

  private func entryView(_ entry: ScanResultEntryType) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      switch entry {
      case .image(let key, let value, let accessibilityLabel):
        KeyValueCustomCell(key: key) {
          Image(data: value)?
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedCorner(radius: .x3))
            .frame(
              maxWidth: resizeImages ? Self.maxImageWidth : nil,
              minHeight: resizeImages ? Self.minHeight : nil,
              maxHeight: resizeImages ? Self.maxImageHeight : nil,
              alignment: resizeImages ? .leading : .center)
            .accessibilityLabel(accessibilityLabel)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, .x2)
      case .text(let key, let value):
        KeyValueCell(key: key, value: value)
          .padding(.trailing, .x4)
          .frame(minHeight: Self.minHeight)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }
}
