import Factory
import Foundation

extension Container {

  public var processInfoService: Factory<ProcessInfoServiceProtocol> {
    self { ProcessInfoService() }
  }

  public var preferredUserLanguageCodes: Factory<[UserLanguageCode]> {
    self {
      self.preferredUserLocales().compactMap {
        guard let sequence = $0.split(separator: "-").first else { return nil }
        return String(sequence)
      } + [UserLanguageCode.defaultAppLanguageCode]
    }
  }

  public var preferredUserLocales: Factory<[UserLocale]> {
    self { Locale.preferredLanguages }
  }

  public var userTimeZone: Factory<TimeZone> {
    self { TimeZone.current }
  }

  public var isProximityEnabled: Factory<Bool> {
    self { false }
  }

  public var imageValidatorEnabled: Factory<Bool> {
    self { false }
  }

  public var imageValidator: Factory<ImageValidatorProtocol> {
    self { ImageValidator() }
  }

  public var supportedImageType: Factory<[ValueType]> {
    self { [.imageJpg, .imagePng] }
  }
}
