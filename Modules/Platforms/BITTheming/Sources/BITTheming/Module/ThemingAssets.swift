// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#elseif os(tvOS) || os(watchOS)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetImageTypeAlias = ImageAsset.Image

// MARK: - ThemingAssets

// swiftlint:disable superfluous_disable_command file_length implicit_return

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum ThemingAssets {
  public enum Gradient {
    public static let gradient1 = ImageAsset(name: "Gradient/Gradient 1")
    public static let gradient2 = ImageAsset(name: "Gradient/Gradient 2")
    public static let gradient3 = ImageAsset(name: "Gradient/Gradient 3")
    public static let gradient4 = ImageAsset(name: "Gradient/Gradient 4")
    public static let gradient5 = ImageAsset(name: "Gradient/Gradient 5")
    public static let gradient6 = ImageAsset(name: "Gradient/Gradient 6")
    public static let gradient7 = ImageAsset(name: "Gradient/Gradient 7")
    public static let gradient8 = ImageAsset(name: "Gradient/Gradient 8")
    public static let gradient9 = ImageAsset(name: "Gradient/Gradient 9")
  }

  public enum Background {
    public enum Button {
      public static let secondary = ColorAsset(name: "Background/Button/Secondary")
    }

    public enum ButtonSheet {
      public static let primary = ColorAsset(name: "Background/ButtonSheet/Primary")
      public static let secondary = ColorAsset(name: "Background/ButtonSheet/Secondary")
    }

    public static let fallback = ColorAsset(name: "Background/Fallback")
    public static let groupedRow = ColorAsset(name: "Background/GroupedRow")
    public static let primary = ColorAsset(name: "Background/Primary")
    public static let secondary = ColorAsset(name: "Background/Secondary")
    public static let system = ColorAsset(name: "Background/System")
    public static let tertiary = ColorAsset(name: "Background/Tertiary")
  }

  public enum Brand {
    public enum Accent {
      public static let blue = ColorAsset(name: "Brand/Accent/Blue")
      public static let green = ColorAsset(name: "Brand/Accent/Green")
      public static let link = ColorAsset(name: "Brand/Accent/Link")
      public static let orange = ColorAsset(name: "Brand/Accent/Orange")
      public static let pink = ColorAsset(name: "Brand/Accent/Pink")
      public static let purple = ColorAsset(name: "Brand/Accent/Purple")
      public static let yellow = ColorAsset(name: "Brand/Accent/Yellow")
    }

    public enum Bright {
      public static let firGreenLabel = ColorAsset(name: "Brand/Bright/Fir Green Label")
      public static let firGreen = ColorAsset(name: "Brand/Bright/Fir Green")
      public static let navyBlueLabel = ColorAsset(name: "Brand/Bright/Navy Blue Label")
      public static let navyBlue = ColorAsset(name: "Brand/Bright/Navy Blue")
      public static let orangeLabel = ColorAsset(name: "Brand/Bright/Orange Label")
      public static let orange = ColorAsset(name: "Brand/Bright/Orange")
      public static let swissRedLabel = ColorAsset(name: "Brand/Bright/Swiss Red Label")
      public static let swissRed = ColorAsset(name: "Brand/Bright/Swiss Red")
      public static let yellowLabel = ColorAsset(name: "Brand/Bright/Yellow Label")
      public static let yellow = ColorAsset(name: "Brand/Bright/Yellow")
    }

    public enum Core {
      public static let black = ColorAsset(name: "Brand/Core/Black")
      public static let crimsonRedLabel = ColorAsset(name: "Brand/Core/Crimson Red Label")
      public static let crimsonRed = ColorAsset(name: "Brand/Core/Crimson Red")
      public static let firGreenLabel = ColorAsset(name: "Brand/Core/Fir Green Label")
      public static let firGreen = ColorAsset(name: "Brand/Core/Fir Green")
      public static let graphite = ColorAsset(name: "Brand/Core/Graphite")
      public static let navyBlueLabel = ColorAsset(name: "Brand/Core/Navy Blue Label")
      public static let navyBlue = ColorAsset(name: "Brand/Core/Navy Blue")
      public static let swissRedLabel = ColorAsset(name: "Brand/Core/Swiss Red Label")
      public static let swissRed = ColorAsset(name: "Brand/Core/Swiss Red")
      public static let white = ColorAsset(name: "Brand/Core/White")
    }

    public enum Shades {
      public static let navyBlue70 = ColorAsset(name: "Brand/Shades/Navy blue 70")
    }
  }

  public enum Fills {
    public static let primary = ColorAsset(name: "Fills/primary")
    public static let secondary = ColorAsset(name: "Fills/secondary")
    public static let tertiary = ColorAsset(name: "Fills/tertiary")
  }

  public enum Grays {
    public static let black = ColorAsset(name: "Grays/Black")
    public static let gray2 = ColorAsset(name: "Grays/Gray 2")
    public static let gray3 = ColorAsset(name: "Grays/Gray 3")
    public static let gray4 = ColorAsset(name: "Grays/Gray 4")
    public static let gray6 = ColorAsset(name: "Grays/Gray 6")
    public static let gray = ColorAsset(name: "Grays/Gray")
    public static let white = ColorAsset(name: "Grays/White")
  }

  public enum Label {
    public static let primary = ColorAsset(name: "Label/primary")
    public static let secondary = ColorAsset(name: "Label/secondary")
    public static let tertiary = ColorAsset(name: "Label/tertiary")
  }

  public enum Materials {
    public static let chrome = ColorAsset(name: "Materials/Chrome")
  }

  public static let back = ImageAsset(name: "Back")
  public static let close = ImageAsset(name: "Close")
  public static let noInternet = ImageAsset(name: "NoInternet")
  public static let backIndicatorBackgroundDark = ImageAsset(name: "back-indicator-background-dark")
  public static let backIndicatorBackground = ImageAsset(name: "back-indicator-background")
  public static let backIndicatorDark = ImageAsset(name: "back-indicator-dark")
  public static let backIndicator = ImageAsset(name: "back-indicator")
  public static let elipsis = ImageAsset(name: "elipsis")
  public static let federalOfficeLogo = ImageAsset(name: "federal-office-logo")
  public static let inAppLogo = ImageAsset(name: "in-app-logo")
  public static let xmark = ImageAsset(name: "xmark")
  public static let navigationAccent = ColorAsset(name: "navigationAccent")
  public static let accentColor = ColorAsset(name: "AccentColor")
  public static let background = ColorAsset(name: "Background")
  public static let gray = ColorAsset(name: "Gray")
  public static let gray2 = ColorAsset(name: "Gray2")
  public static let gray3 = ColorAsset(name: "Gray3")
  public static let gray4 = ColorAsset(name: "Gray4")
  public static let gray5 = ColorAsset(name: "Gray5")
  public static let green2 = ColorAsset(name: "Green2")
  public static let orange2 = ColorAsset(name: "Orange2")
  public static let petrol = ColorAsset(name: "Petrol")
  public static let petrol2 = ColorAsset(name: "Petrol2")
  public static let petrol3 = ColorAsset(name: "Petrol3")
  public static let primaryReversed = ColorAsset(name: "PrimaryReversed")
  public static let red = ColorAsset(name: "Red")
  public static let red2 = ColorAsset(name: "Red2")
  public static let red3 = ColorAsset(name: "Red3")
  public static let secondary = ColorAsset(name: "Secondary")
  public static let secondaryReversed = ColorAsset(name: "SecondaryReversed")
}

// MARK: - ColorAsset

// swiftlint:enable identifier_name line_length nesting type_body_length type_name

public final class ColorAsset {

  // MARK: Lifecycle

  fileprivate init(name: String) {
    self.name = name
  }

  // MARK: Public

  #if os(macOS)
  public typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Color = UIColor
  #endif

  public fileprivate(set) var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  public private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public private(set) lazy var swiftUIColor = SwiftUI.Color(asset: self)
  #endif

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  public func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

}

extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  public convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
extension SwiftUI.Color {
  public init(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

// MARK: - ImageAsset

public struct ImageAsset {
  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  public fileprivate(set) var name: String

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  public var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  public func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

}

extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(
    macOS,
    deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  public convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
extension SwiftUI.Image {
  public init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  public init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  public init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
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
