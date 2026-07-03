import BITL10n
import Foundation
import SwiftUI

// MARK: - KeyValueCell

public struct KeyValueCell<Content: View>: View {

  // MARK: Lifecycle

  public init(
    key: String,
    value: String,
    lineLimit: Int? = nil,
    showClaimKey: Bool = true,
    @ViewBuilder trailingContent: @escaping () -> Content = { EmptyView() })
  {
    self.key = key
    self.value = value
    self.trailingContent = trailingContent
    self.lineLimit = lineLimit
    self.showClaimKey = showClaimKey
  }

  // MARK: Public

  public var body: some View {
    KeyValueCustomCell(key: key, showClaimKey: showClaimKey, trailingContent: trailingContent) {
      Text(value)
        .font(.custom.body)
        .lineLimit(lineLimit)
        .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
        .accessibilityIdentifier(key)
    }
  }

  // MARK: Internal

  var key: String
  var value: String
  var trailingContent: () -> Content
  var lineLimit: Int? = 4
  var showClaimKey: Bool
}

// MARK: - KeyValueCustomCell

public struct KeyValueCustomCell<Content: View, TrailingContent: View>: View {

  // MARK: Lifecycle

  public init(
    key: String,
    showClaimKey: Bool = true,
    @ViewBuilder trailingContent: () -> TrailingContent = { EmptyView() },
    @ViewBuilder _ content: () -> Content)
  {
    self.key = key
    self.showClaimKey = showClaimKey
    self.content = content()
    self.trailingContent = trailingContent()
  }

  // MARK: Public

  public var body: some View {
    HStack(alignment: .center, spacing: 0) {
      VStack(alignment: .leading, spacing: .x1) {
        if showClaimKey {
          Text(key)
            .font(.custom.caption1)
            .foregroundColor(ThemingAssets.Label.secondary.swiftUIColor)
        }

        content
      }
      Spacer()
      trailingContent
        .minimumScaleFactor(0.5)
        .padding(.leading, TrailingContent.self == EmptyView.self ? 0 : .x2)
    }
    .padding(.vertical, .x2)
    .accessibilityElement(children: .combine)
  }

  // MARK: Private

  private var key: String
  private let showClaimKey: Bool
  private let content: Content
  private let trailingContent: TrailingContent
}

// MARK: - IconKeyValueCell

public struct IconKeyValueCell<Content: View>: View {

  // MARK: Lifecycle

  public init(
    key: String,
    value: String,
    image: Image,
    @ViewBuilder trailingContent: @escaping () -> Content = { EmptyView() },
    onTap: (() -> Void)? = nil)
  {
    self.key = key
    self.value = value
    self.image = image
    self.trailingContent = trailingContent
    self.onTap = onTap
  }

  // MARK: Public

  public var body: some View {
    KeyValueCustomCell(key: key, trailingContent: trailingContent) {
      Button(action: { onTap?() }, label: {
        HStack(alignment: .top, spacing: .x4) {
          VStack {
            image
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: imageWidth, height: imageHeight)
          }
          .frame(width: 30)

          VStack(alignment: .leading) {
            HStack(spacing: .x2) {
              Text(value)
                .font(.custom.body)
                .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
                .accessibilityLabel(value)
                .multilineTextAlignment(.leading)
            }
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

  private let imageHeight: CGFloat = 25
  private let imageWidth: CGFloat = 22

  private let key: String
  private let value: String
  private let image: Image
  private let trailingContent: () -> Content
  private var onTap: (() -> Void)?
}

#Preview {
  VStack(alignment: .leading) {
    KeyValueCell(key: "Test", value: "Value")
    KeyValueCell(key: "Test", value: "Value") {
      Badge(label: "Test")
        .badgeStyle(.error)
    }
    KeyValueCustomCell(key: "Test", {
      Label(
        title: { Text("Label") },
        icon: { Image(systemName: "42.circle") })
    })
    IconKeyValueCell(key: "Label", value: "Icon", image: Image(systemName: "42.circle"), trailingContent: {
      Badge(label: "Test")
        .badgeStyle(.error)
    })
  }
}
