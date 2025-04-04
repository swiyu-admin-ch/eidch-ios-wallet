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
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
typealias AssetImageTypeAlias = ImageAsset.Image

// MARK: - Assets

// swiftlint:disable superfluous_disable_command file_length implicit_return

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
enum Assets {
  static let camera = ImageAsset(name: "Camera")
  static let card = ImageAsset(name: "Card")
  static let checkCard = ImageAsset(name: "CheckCard")
  static let close = ImageAsset(name: "Close")
  static let eidRequestCaseIcon = ImageAsset(name: "EIDRequestCaseIcon")
  static let shield = ImageAsset(name: "Shield")
  static let timer = ImageAsset(name: "Timer")
  static let walletPairing = ImageAsset(name: "WalletPairing")
}

// MARK: - ImageAsset

// swiftlint:enable identifier_name line_length nesting type_body_length type_name

struct ImageAsset {
  #if os(macOS)
  typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  typealias Image = UIImage
  #endif

  fileprivate(set) var name: String

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  var image: Image {
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
  var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  func image(compatibleWith traitCollection: UITraitCollection) -> Image {
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
  convenience init?(asset: ImageAsset) {
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
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
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
