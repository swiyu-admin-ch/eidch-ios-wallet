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

  private func entryView(_ entry: ScanResultEntryType) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      switch entry {
      case .image(let image):
        KeyValueCustomCell(key: image.key) {
          VStack(spacing: .x2) {
            imageView(for: image)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, .x2)
      case .text(let key, let value):
        KeyValueCell(key: key, value: value)
          .padding(.trailing, .x4)
          .frame(minHeight: minHeight)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .accessibilityElement(children: .combine)
    .if(entry == entries.first) { $0.accessibilityPriorityFocus() }
  }

  private func imageView(for image: ScanResultEntryImage) -> some View {
    Image(data: image.value)?
      .resizable()
      .aspectRatio(contentMode: .fit)
      .clipShape(RoundedCorner(radius: .x3))
      .frame(
        maxWidth: resizeImages ? maxImageWidth : nil,
        minHeight: resizeImages ? minHeight : nil,
        maxHeight: resizeImages ? maxImageHeight : nil,
        alignment: resizeImages ? .leading : .center)
      .overlay(alignment: .bottomTrailing) {
        imageOverviewButton(for: image)
      }
      .accessibilityLabel(image.accessibilityLabel)
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
      .contentShape(.accessibility, .circle)
      .padding(.x2_5)
    }
  }
}
