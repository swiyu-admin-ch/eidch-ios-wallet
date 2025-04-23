import BITL10n
import Foundation
import SwiftUI

// MARK: - KeyValueCell

public struct KeyValueCell: View {

  // MARK: Lifecycle

  public init(key: String, value: String, lineLimit: Int? = nil) {
    self.key = key
    self.value = value
    self.lineLimit = lineLimit
  }

  // MARK: Public

  public var body: some View {
    KeyValueCustomCell(key: key) {
      Text(value)
        .font(.custom.body)
        .lineLimit(lineLimit)
        .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
        .accessibilityLabel("\(L10n.cellValueAccessibilityLabel) \(value)")
        .accessibilityIdentifier(key)
    }
  }

  // MARK: Internal

  var key: String
  var value: String
  var lineLimit: Int? = 4
}

// MARK: - KeyValueCustomCell

public struct KeyValueCustomCell<Content: View>: View {

  // MARK: Lifecycle

  public init(key: String, @ViewBuilder _ content: () -> Content) {
    self.key = key
    self.content = content()
  }

  // MARK: Public

  public var body: some View {
    VStack(alignment: .leading, spacing: .x1) {
      Text(key)
        .font(.custom.caption1)
        .foregroundColor(ThemingAssets.Label.secondary.swiftUIColor)
        .accessibilityHidden(true)
      content
    }
    .accessibilityElement(children: .contain)
    .accessibilityLabel(key)
  }

  // MARK: Private

  private var key: String
  private let content: Content
}

// MARK: - IconKeyValueCell

public struct IconKeyValueCell: View {

  // MARK: Lifecycle

  public init(key: String, value: String, image: Image, disclosureIndicator: Image, onTap: (() -> Void)? = nil) {
    self.key = key
    self.value = value
    self.image = image
    self.disclosureIndicator = disclosureIndicator
    self.onTap = onTap
  }

  // MARK: Public

  public var body: some View {
    KeyValueCustomCell(key: key) {
      Button(action: { onTap?() }, label: {
        HStack(alignment: .top, spacing: .x4) {
          VStack {
            image
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: Const.imageWidth, height: Const.imageHeight)
          }
          .frame(width: 30)

          VStack(alignment: .leading) {
            HStack(spacing: .x2) {
              Text(value)
                .font(.custom.body)
                .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
                .accessibilityLabel(value)
                .multilineTextAlignment(.leading)

              Spacer()

              disclosureIndicator
                .padding(.trailing, .x6)
            }

            Divider()
          }
        }
      }).accessibilityIdentifier(AccessibilityIdentifier.button.rawValue)
    }
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case button
  }

  // MARK: Private

  private enum Const {
    static let imageHeight: CGFloat = 25
    static let imageWidth: CGFloat = 22
  }

  private let key: String
  private let value: String
  private let image: Image
  private let disclosureIndicator: Image
  private var onTap: (() -> Void)?
}

#Preview {
  VStack(alignment: .leading) {
    KeyValueCell(key: "Test", value: "Value")
    KeyValueCustomCell(key: "Test", {
      Label(
        title: { Text("Label") },
        icon: { Image(systemName: "42.circle") })
    })
  }
}
