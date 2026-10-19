import Foundation
import SwiftUI
import UIKit

extension UIFont {

  public class func preferredFont(forTextStyle style: UIFont.TextStyle, font: FontConvertible, size: CGFloat? = nil) -> UIFont {
    let metrics = UIFontMetrics(forTextStyle: style)
    let descriptor = preferredFont(forTextStyle: style).fontDescriptor
    let defaultSize = descriptor.pointSize
    let fontToScale: UIFont = font.font(size: size ?? defaultSize)
    return metrics.scaledFont(for: fontToScale)
  }

}

extension SwiftUI.Font {
  public static let custom = ABCDiatype.self
  public static let mono = ABCDiatypeRoundedSemiMono.self
}

// MARK: - SwiftUI.Font.ABCDiatype

extension SwiftUI.Font {
  public struct ABCDiatype {
    public static let titleLarge: SwiftUI.Font = FontFamily.ABCDiatype.regular.swiftUIFont(size: 34, relativeTo: .largeTitle)
    public static let titleLargeEmphasized: SwiftUI.Font = FontFamily.ABCDiatype.medium.swiftUIFont(size: 34, relativeTo: .largeTitle)

    public static let title: SwiftUI.Font = FontFamily.ABCDiatype.regular.swiftUIFont(size: 28, relativeTo: .title)
    public static let titleEmphasized: SwiftUI.Font = FontFamily.ABCDiatype.medium.swiftUIFont(size: 28, relativeTo: .title)

    public static let title2: SwiftUI.Font = FontFamily.ABCDiatype.regular.swiftUIFont(size: 22, relativeTo: .title2)
    public static let title2Emphasized: SwiftUI.Font = FontFamily.ABCDiatype.medium.swiftUIFont(size: 22, relativeTo: .title2)

    public static let title3: SwiftUI.Font = FontFamily.ABCDiatype.regular.swiftUIFont(size: 20, relativeTo: .title2)
    public static let title3Emphasized: SwiftUI.Font = FontFamily.ABCDiatype.medium.swiftUIFont(size: 20, relativeTo: .title2)

    public static let headline: SwiftUI.Font = FontFamily.ABCDiatype.medium.swiftUIFont(size: 17, relativeTo: .headline)
    public static let headlineEmphasized: SwiftUI.Font = FontFamily.ABCDiatype.regularItalic.swiftUIFont(size: 17, relativeTo: .headline)

    public static let body: SwiftUI.Font = FontFamily.ABCDiatype.regular.swiftUIFont(size: 17, relativeTo: .body)
    public static let bodyItalic: SwiftUI.Font = FontFamily.ABCDiatype.regularItalic.swiftUIFont(size: 17, relativeTo: .body)
    public static let bodyEmphasized: SwiftUI.Font = FontFamily.ABCDiatype.medium.swiftUIFont(size: 17, relativeTo: .body)
    public static let bodyItalicEmphasized: SwiftUI.Font = FontFamily.ABCDiatype.mediumItalic.swiftUIFont(size: 17, relativeTo: .body)
    public static let bodyBold: SwiftUI.Font = FontFamily.ABCDiatype.bold.swiftUIFont(size: 17, relativeTo: .body)

    public static let callout: SwiftUI.Font = FontFamily.ABCDiatype.regular.swiftUIFont(size: 16, relativeTo: .callout)
    public static let calloutItalic: SwiftUI.Font = FontFamily.ABCDiatype.regularItalic.swiftUIFont(size: 16, relativeTo: .callout)
    public static let calloutEmphasized: SwiftUI.Font = FontFamily.ABCDiatype.medium.swiftUIFont(size: 16, relativeTo: .callout)
    public static let calloutItalicEmphasized: SwiftUI.Font = FontFamily.ABCDiatype.mediumItalic.swiftUIFont(size: 16, relativeTo: .callout)

    public static let subheadline: SwiftUI.Font = FontFamily.ABCDiatype.regular.swiftUIFont(size: 15, relativeTo: .subheadline)
    public static let subheadlineItalic: SwiftUI.Font = FontFamily.ABCDiatype.regularItalic.swiftUIFont(size: 15, relativeTo: .subheadline)
    public static let subheadlineEmphasized: SwiftUI.Font = FontFamily.ABCDiatype.medium.swiftUIFont(size: 15, relativeTo: .subheadline)
    public static let subheadlineItalicEmphasized: SwiftUI.Font = FontFamily.ABCDiatype.mediumItalic.swiftUIFont(size: 15, relativeTo: .subheadline)

    public static let footnote: SwiftUI.Font = FontFamily.ABCDiatype.regular.swiftUIFont(size: 13, relativeTo: .footnote)
    public static let footnoteItalic: SwiftUI.Font = FontFamily.ABCDiatype.regularItalic.swiftUIFont(size: 13, relativeTo: .footnote)
    public static let footnoteEmphasized: SwiftUI.Font = FontFamily.ABCDiatype.medium.swiftUIFont(size: 13, relativeTo: .footnote)
    public static let footnoteItalicEmphasized: SwiftUI.Font = FontFamily.ABCDiatype.mediumItalic.swiftUIFont(size: 13, relativeTo: .footnote)

    public static let caption1: SwiftUI.Font = FontFamily.ABCDiatype.regular.swiftUIFont(size: 12, relativeTo: .caption)
    public static let caption1Italic: SwiftUI.Font = FontFamily.ABCDiatype.regularItalic.swiftUIFont(size: 12, relativeTo: .caption)
    public static let caption1Emphasized: SwiftUI.Font = FontFamily.ABCDiatype.medium.swiftUIFont(size: 12, relativeTo: .caption)
    public static let caption1ItalicEmphasized: SwiftUI.Font = FontFamily.ABCDiatype.mediumItalic.swiftUIFont(size: 12, relativeTo: .caption)

    public static let caption2: SwiftUI.Font = FontFamily.ABCDiatype.regular.swiftUIFont(size: 11, relativeTo: .caption2)
    public static let caption2Italic: SwiftUI.Font = FontFamily.ABCDiatype.regularItalic.swiftUIFont(size: 11, relativeTo: .caption2)
    public static let caption2Emphasized: SwiftUI.Font = FontFamily.ABCDiatype.medium.swiftUIFont(size: 11, relativeTo: .caption2)
    public static let caption2ItalicEmphasized: SwiftUI.Font = FontFamily.ABCDiatype.mediumItalic.swiftUIFont(size: 11, relativeTo: .caption2)
  }

  public struct ABCDiatypeRoundedSemiMono {
    public static let title: SwiftUI.Font = FontFamily.ABCDiatypeRoundedSemiMono.medium.swiftUIFont(size: 24, relativeTo: .title)
    public static let title2: SwiftUI.Font = FontFamily.ABCDiatypeRoundedSemiMono.medium.swiftUIFont(size: 18, relativeTo: .title2)
    public static let headline: SwiftUI.Font = FontFamily.ABCDiatypeRoundedSemiMono.medium.swiftUIFont(size: 16, relativeTo: .headline)
    public static let headline2: SwiftUI.Font = FontFamily.ABCDiatypeRoundedSemiMono.medium.swiftUIFont(size: 16, relativeTo: .headline)
    public static let body: SwiftUI.Font = FontFamily.ABCDiatypeRoundedSemiMono.regular.swiftUIFont(size: 16, relativeTo: .body)
    public static let textLink: SwiftUI.Font = FontFamily.ABCDiatypeRoundedSemiMono.regular.swiftUIFont(size: 16, relativeTo: .body)
    public static let textLink2: SwiftUI.Font = FontFamily.ABCDiatypeRoundedSemiMono.bold.swiftUIFont(size: 12, relativeTo: .body)
    public static let subheadline: SwiftUI.Font = FontFamily.ABCDiatypeRoundedSemiMono.regular.swiftUIFont(size: 14, relativeTo: .subheadline)
    public static let footnote: SwiftUI.Font = FontFamily.ABCDiatypeRoundedSemiMono.medium.swiftUIFont(size: 12, relativeTo: .footnote)
    public static let footnote2: SwiftUI.Font = FontFamily.ABCDiatypeRoundedSemiMono.regular.swiftUIFont(size: 12, relativeTo: .footnote)
    public static let light: SwiftUI.Font = FontFamily.ABCDiatypeRoundedSemiMono.light.swiftUIFont(size: 12)
  }
}
