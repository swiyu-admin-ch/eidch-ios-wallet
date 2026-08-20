import Factory
import Foundation
import UIKit

extension Container {

  // MARK: Public

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

  public var appLanguageService: Factory<AppLanguageServiceProtocol> {
    self { AppLanguageService() }
  }

  public var userTimeZone: Factory<TimeZone> {
    self { TimeZone.current }
  }

  public var isProximityEnabled: Factory<Bool> {
    self { false }
  }

  public var imageValidator: Factory<ImageValidatorProtocol> {
    self { ImageValidator() }
  }

  public var supportedImageType: Factory<[ValueType]> {
    self { [.imageJpg, .imagePng] }
  }

  public var currentDate: Factory<Date> {
    self { Date() }
  }

  public var calendar: Factory<Calendar> {
    self { Calendar.current }
  }

  public var applicationService: Factory<ApplicationServiceProtocol> {
    self { UIApplication.shared }.singleton
  }

  /// Maximum execution time for regex-based validators evaluating untrusted input.
  public var regexEvaluationTimeout: Factory<TimeInterval> {
    self { 0.3 }
  }

  /// Maximum accepted length for an HTTP URL, in characters (ReDoS mitigation).
  public var maxHttpUrlLength: Factory<Int> {
    self { 2048 }
  }

  // MARK: Internal

  var appGroupIdentifier: Factory<String> {
    self {
      guard let appGroupIdentifier = Bundle.main.object(forInfoDictionaryKey: "AppGroupIdentifier") as? String else {
        fatalError("Missing AppGroupIdentifier in Info.plist")
      }
      return appGroupIdentifier
    }
  }

}
