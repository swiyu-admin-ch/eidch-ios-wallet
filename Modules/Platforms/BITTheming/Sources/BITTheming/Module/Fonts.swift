// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen
// based on the original fonts-swift5.stencil
//   - swiftgen template cat fonts swift
// changelog:
//   - update the func 'font(size: CGFloat) -> Font' to return a default Font instead of execute a fatalError

#if os(macOS)
import AppKit.NSFont
#elseif os(iOS) || os(tvOS) || os(watchOS)
import UIKit.UIFont
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

/// Deprecated typealiases
@available(*, deprecated, renamed: "FontConvertible.Font", message: "This typealias will be removed in SwiftGen 7.0")
public typealias Font = FontConvertible.Font

// MARK: - FontFamily

// swiftlint:disable superfluous_disable_command file_length implicit_return

// swiftlint:disable identifier_name line_length type_body_length
public enum FontFamily {
  public enum ABCDiatype {
    public static let black = FontConvertible(name: "ABCDiatype-Black", family: "ABC Diatype", path: "ABCDiatype-Black.otf")
    public static let blackItalic = FontConvertible(name: "ABCDiatype-BlackItalic", family: "ABC Diatype", path: "ABCDiatype-BlackItalic.otf")
    public static let bold = FontConvertible(name: "ABCDiatype-Bold", family: "ABC Diatype", path: "ABCDiatype-Bold.otf")
    public static let boldItalic = FontConvertible(name: "ABCDiatype-BoldItalic", family: "ABC Diatype", path: "ABCDiatype-BoldItalic.otf")
    public static let heavy = FontConvertible(name: "ABCDiatype-Heavy", family: "ABC Diatype", path: "ABCDiatype-Heavy.otf")
    public static let heavyItalic = FontConvertible(name: "ABCDiatype-HeavyItalic", family: "ABC Diatype", path: "ABCDiatype-HeavyItalic.otf")
    public static let light = FontConvertible(name: "ABCDiatype-Light", family: "ABC Diatype", path: "ABCDiatype-Light.otf")
    public static let lightItalic = FontConvertible(name: "ABCDiatype-LightItalic", family: "ABC Diatype", path: "ABCDiatype-LightItalic.otf")
    public static let medium = FontConvertible(name: "ABCDiatype-Medium", family: "ABC Diatype", path: "ABCDiatype-Medium.otf")
    public static let mediumItalic = FontConvertible(name: "ABCDiatype-MediumItalic", family: "ABC Diatype", path: "ABCDiatype-MediumItalic.otf")
    public static let regular = FontConvertible(name: "ABCDiatype-Regular", family: "ABC Diatype", path: "ABCDiatype-Regular.otf")
    public static let regularItalic = FontConvertible(name: "ABCDiatype-RegularItalic", family: "ABC Diatype", path: "ABCDiatype-RegularItalic.otf")
    public static let thin = FontConvertible(name: "ABCDiatype-Thin", family: "ABC Diatype", path: "ABCDiatype-Thin.otf")
    public static let thinItalic = FontConvertible(name: "ABCDiatype-ThinItalic", family: "ABC Diatype", path: "ABCDiatype-ThinItalic.otf")
    public static let ultra = FontConvertible(name: "ABCDiatype-Ultra", family: "ABC Diatype", path: "ABCDiatype-Ultra.otf")
    public static let ultraItalic = FontConvertible(name: "ABCDiatype-UltraItalic", family: "ABC Diatype", path: "ABCDiatype-UltraItalic.otf")
    public static let all: [FontConvertible] = [black, blackItalic, bold, boldItalic, heavy, heavyItalic, light, lightItalic, medium, mediumItalic, regular, regularItalic, thin, thinItalic, ultra, ultraItalic]
  }

  public enum ABCDiatypeRoundedSemiMono {
    public static let bold = FontConvertible(name: "ABCDiatypeRoundedSemi-Mono-Bold", family: "ABC Diatype Rounded Semi-Mono", path: "ABCDiatypeRoundedSemi-Mono-Bold.otf")
    public static let boldItalic = FontConvertible(name: "ABCDiatypeRoundedSemi-Mono-BoldItalic", family: "ABC Diatype Rounded Semi-Mono", path: "ABCDiatypeRoundedSemi-Mono-BoldItalic.otf")
    public static let light = FontConvertible(name: "ABCDiatypeRoundedSemi-Mono-Light", family: "ABC Diatype Rounded Semi-Mono", path: "ABCDiatypeRoundedSemi-Mono-Light.otf")
    public static let lightItalic = FontConvertible(name: "ABCDiatypeRoundedSemi-Mono-LightItalic", family: "ABC Diatype Rounded Semi-Mono", path: "ABCDiatypeRoundedSemi-Mono-LightItalic.otf")
    public static let medium = FontConvertible(name: "ABCDiatypeRoundedSemi-Mono-Medium", family: "ABC Diatype Rounded Semi-Mono", path: "ABCDiatypeRoundedSemi-Mono-Medium.otf")
    public static let mediumItalic = FontConvertible(name: "ABCDiatypeRoundedSemi-Mono-MediumItalic", family: "ABC Diatype Rounded Semi-Mono", path: "ABCDiatypeRoundedSemi-Mono-MediumItalic.otf")
    public static let regular = FontConvertible(name: "ABCDiatypeRoundedSemi-Mono-Regular", family: "ABC Diatype Rounded Semi-Mono", path: "ABCDiatypeRoundedSemi-Mono-Regular.otf")
    public static let regularItalic = FontConvertible(name: "ABCDiatypeRoundedSemi-Mono-RegularItalic", family: "ABC Diatype Rounded Semi-Mono", path: "ABCDiatypeRoundedSemi-Mono-RegularItalic.otf")
    public static let thin = FontConvertible(name: "ABCDiatypeRoundedSemi-Mono-Thin", family: "ABC Diatype Rounded Semi-Mono", path: "ABCDiatypeRoundedSemi-Mono-Thin.otf")
    public static let thinItalic = FontConvertible(name: "ABCDiatypeRoundedSemi-Mono-ThinItalic", family: "ABC Diatype Rounded Semi-Mono", path: "ABCDiatypeRoundedSemi-Mono-ThinItalic.otf")
    public static let all: [FontConvertible] = [bold, boldItalic, light, lightItalic, medium, mediumItalic, regular, regularItalic, thin, thinItalic]
  }

  public static let allCustomFonts: [FontConvertible] = [ABCDiatype.all, ABCDiatypeRoundedSemiMono.all].flatMap { $0 }

  public static func registerAllCustomFonts() {
    allCustomFonts.forEach { $0.register() }
  }
}

// MARK: - FontConvertible

// swiftlint:enable identifier_name line_length type_body_length

public struct FontConvertible {

  // MARK: Public

  #if os(macOS)
  public typealias Font = NSFont
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Font = UIFont
  #endif

  public let name: String
  public let family: String
  public let path: String

  public func font(size: CGFloat) -> Font {
    guard let font = Font(font: self, size: size) else {
      return Font.systemFont(ofSize: size)
    }
    return font
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public func swiftUIFont(size: CGFloat) -> SwiftUI.Font {
    SwiftUI.Font.custom(self, size: size)
  }

  @available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *)
  public func swiftUIFont(fixedSize: CGFloat) -> SwiftUI.Font {
    SwiftUI.Font.custom(self, fixedSize: fixedSize)
  }

  @available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *)
  public func swiftUIFont(size: CGFloat, relativeTo textStyle: SwiftUI.Font.TextStyle) -> SwiftUI.Font {
    SwiftUI.Font.custom(self, size: size, relativeTo: textStyle)
  }
  #endif

  public func register() {
    // swiftlint:disable:next conditional_returns_on_newline
    guard let url else { return }
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
  }

  // MARK: Fileprivate

  fileprivate var url: URL? {
    // swiftlint:disable:next implicit_return
    BundleToken.bundle.url(forResource: path, withExtension: nil)
  }

  fileprivate func registerIfNeeded() {
    #if os(iOS) || os(tvOS) || os(watchOS)
    if !UIFont.fontNames(forFamilyName: family).contains(name) {
      register()
    }
    #elseif os(macOS)
    if let url, CTFontManagerGetScopeForURL(url as CFURL) == .none {
      register()
    }
    #endif
  }

}

extension FontConvertible.Font {
  public convenience init?(font: FontConvertible, size: CGFloat) {
    font.registerIfNeeded()
    self.init(name: font.name, size: size)
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
extension SwiftUI.Font {
  public static func custom(_ font: FontConvertible, size: CGFloat) -> SwiftUI.Font {
    font.registerIfNeeded()
    return custom(font.name, size: size)
  }
}

@available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *)
extension SwiftUI.Font {
  public static func custom(_ font: FontConvertible, fixedSize: CGFloat) -> SwiftUI.Font {
    font.registerIfNeeded()
    return custom(font.name, fixedSize: fixedSize)
  }

  public static func custom(
    _ font: FontConvertible,
    size: CGFloat,
    relativeTo textStyle: SwiftUI.Font.TextStyle)
    -> SwiftUI.Font
  {
    font.registerIfNeeded()
    return custom(font.name, size: size, relativeTo: textStyle)
  }
}
#endif

// MARK: - BundleToken

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}

// swiftlint:enable convenience_type
