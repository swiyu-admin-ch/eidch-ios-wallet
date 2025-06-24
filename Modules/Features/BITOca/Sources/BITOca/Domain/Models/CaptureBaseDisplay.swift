import BITCore
import Foundation

public struct CaptureBaseDisplay: Equatable {

  // MARK: Lifecycle

  public init(
    captureBaseDigest: String,
    language: String,
    theme: String? = nil,
    logo: URL? = nil,
    backgroundImage: URL? = nil,
    backgroundImageSlice: String? = nil,
    primaryBackgroundColor: String? = nil,
    secondaryBackgroundColor: String? = nil,
    primaryField: String? = nil,
    secondaryField: String? = nil,
    metaName: String? = nil,
    metaDescription: String? = nil)
  {
    self.captureBaseDigest = captureBaseDigest
    self.language = language
    self.theme = theme
    self.logo = logo
    self.backgroundImage = backgroundImage
    self.backgroundImageSlice = backgroundImageSlice
    self.primaryBackgroundColor = primaryBackgroundColor
    self.secondaryBackgroundColor = secondaryBackgroundColor
    self.primaryField = primaryField
    self.secondaryField = secondaryField
    self.metaName = metaName
    self.metaDescription = metaDescription
  }

  // MARK: Public

  public let captureBaseDigest: String
  public let language: String
  public let theme: String?
  public let logo: URL?
  public let backgroundImage: URL?
  public let backgroundImageSlice: String?
  public let primaryBackgroundColor: String?
  public let secondaryBackgroundColor: String?
  public let primaryField: String?
  public let secondaryField: String?
  public let metaName: String?
  public let metaDescription: String?
}
