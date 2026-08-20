import BITL10n
import BITTheming
import SwiftUI

struct ScanResultListView: View {

  // MARK: Lifecycle

  init(entries: [ScanResultEntryType], resizeImages: Bool = false, buttonAction: ((ScanResultEntryImage) -> Void)? = nil) {
    self.entries = entries
    self.resizeImages = resizeImages
    self.buttonAction = buttonAction
  }

  // MARK: Internal

  var body: some View {
    ForEach(entries, id: \.self) { entry in
      entryView(entry)
        .padding(.leading, .x4)
    }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  private let resizeImages: Bool
  private let entries: [ScanResultEntryType]
  private let buttonAction: ((ScanResultEntryImage) -> Void)?

  private let minHeight: CGFloat = 60
  private let maxImageWidth: CGFloat = 120
  private let maxImageHeight: CGFloat = 120
  private let expendButtonSize = CGFloat.x8

  @ViewBuilder
  private func entryView(_ entry: ScanResultEntryType) -> some View {
    switch entry {
    case .image(let image):
      imageEntryView(image, isFirstScan: entry == entries.first)

    case .text(let key, let value):
      KeyValueCell(key: key, value: value)
        .padding(.trailing, .x4)
        .frame(minHeight: minHeight)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private func imageEntryView(_ image: ScanResultEntryImage, isFirstScan: Bool) -> some View {
    let axLabel = [
      image.accessibilityLabel,
      L10n.tkEidRequestScanDocumentSubmitScanImageExpandButtonAlt,
    ].joined(separator: ", ")

    return KeyValueCustomCell(key: image.key) {
      Image(data: image.value)?
        .resizable()
        .aspectRatio(contentMode: .fit)
        .clipShape(RoundedCorner(radius: .x3))
        .frame(
          maxWidth: resizeImages ? maxImageWidth : nil,
          minHeight: resizeImages ? minHeight : nil,
          maxHeight: resizeImages ? maxImageHeight : nil,
          alignment: resizeImages ? .leading : .center)
        .accessibilityRemoveTraits(.isImage)
        .overlay(alignment: .bottomTrailing) {
          imageOverviewButton(for: image)
        }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.top, .x1)
    .padding(.trailing, .x2)
    .padding(.bottom, .x2)
    .accessibilityAddTraits(.isButton)
    .accessibilityLabel(axLabel)
    .if(isFirstScan) { $0.accessibilityPriorityFocus(delay: .seconds(0)) }
  }

  @ViewBuilder
  private func imageOverviewButton(for image: ScanResultEntryImage) -> some View {
    if let buttonAction {
      Button {
        buttonAction(image)
      } label: {
        Image(systemName: "arrow.down.left.and.arrow.up.right")
          .font(.custom.callout)
          .padding(.x2)
          .background(ThemingAssets.Background.Button.secondary.swiftUIColor, in: .circle)
      }
      .padding(.x2_5)
      .accessibilityHidden(true)
    }
  }
}
