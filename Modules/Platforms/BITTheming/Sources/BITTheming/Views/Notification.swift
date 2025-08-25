import Foundation
import SwiftUI

// MARK: - Notification

public struct Notification: View {

  // MARK: Lifecycle

  public init(
    image: Image? = nil,
    imageColor: Color? = nil,
    title: String? = nil,
    titleColor: Color? = nil,
    content: String,
    contentColor: Color? = nil,
    subtitle: String? = nil,
    subtitleColor: Color? = nil,
    closeAction: @escaping () -> Void,
    subtitleAction: (() -> Void)? = nil,
    background: Color = ThemingAssets.Brand.Core.swissRedLabel.swiftUIColor,
    closeButtonStyle: CustomButtonStyle = .bezeledLightDestructive)
  {
    self.image = image
    self.imageColor = imageColor
    self.title = title
    self.titleColor = titleColor
    self.content = content
    self.contentColor = contentColor
    self.subtitle = subtitle
    self.closeAction = closeAction
    self.subtitleAction = subtitleAction
    self.background = background
    self.closeButtonStyle = closeButtonStyle
  }

  public init(
    systemImageName: String,
    imageColor: Color? = nil,
    title: String? = nil,
    titleColor: Color? = nil,
    content: String,
    contentColor: Color? = nil,
    subtitle: String? = nil,
    subtitleColor: Color? = nil,
    closeAction: @escaping () -> Void,
    subtitleAction: (() -> Void)? = nil,
    background: Color = ThemingAssets.Brand.Core.swissRedLabel.swiftUIColor,
    closeButtonStyle: CustomButtonStyle = .bezeledLightDestructive)
  {
    image = Image(systemName: systemImageName)
    self.imageColor = imageColor
    self.title = title
    self.titleColor = titleColor
    self.content = content
    self.contentColor = contentColor
    self.subtitle = subtitle
    self.subtitleColor = subtitleColor
    self.closeAction = closeAction
    self.subtitleAction = subtitleAction
    self.background = background
    self.closeButtonStyle = closeButtonStyle
  }

  // MARK: Public

  public var body: some View {
    HStack(alignment: .top) {
      HStack(alignment: .center, spacing: .x4) {
        if !sizeCategory.isAccessibilityCategory {
          image?.accessibilityHidden(true)
            .foregroundColor(imageColor)
        }

        VStack(alignment: .leading) {
          if let title {
            Text(title)
              .font(.custom.footnoteEmphasized)
              .foregroundColor(titleColor)
              .accessibilityLabel(title)
          }

          Text(content)
            .font(.custom.footnote)
            .foregroundColor(contentColor)
            .accessibilityLabel(content)

          if let subtitle, let subtitleAction {
            ButtonLinkText(subtitle, subtitleAction)
              .font(.custom.footnote)
              .foregroundColor(subtitleColor)
              .accessibilityLabel(subtitle)
          }
        }
      }
      .padding(sizeCategory.isAccessibilityCategory ? .x2 : .x4)
      .accessibilityElement(children: .combine)

      Spacer()

      CircleButton(action: { closeAction() }, imageSystemName: "xmark")
        .buttonStyle(closeButtonStyle)
        .padding(.top, .x2)
    }
    .frame(maxWidth: horizontalSizeClass == .regular && verticalSizeClass == .compact ? (sizeCategory.isAccessibilityCategory ? .infinity : 350) : .infinity)
    .background(background)
    .cornerRadius(.CornerRadius.m)
  }

  // MARK: Internal

  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @Environment(\.verticalSizeClass) var verticalSizeClass
  @Environment(\.sizeCategory) var sizeCategory

  // MARK: Private

  private var image: Image?
  private var imageColor: Color?
  private var title: String?
  private var titleColor: Color?
  private var content: String
  private var contentColor: Color?
  private var subtitle: String?
  private var subtitleColor: Color?
  private var closeAction: () -> Void
  private var subtitleAction: (() -> Void)?
  private var background: Color
  private var closeButtonStyle: CustomButtonStyle
}
