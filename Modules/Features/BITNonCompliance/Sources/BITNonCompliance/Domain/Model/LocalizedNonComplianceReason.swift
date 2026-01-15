import BITCore
import Factory

public struct LocalizedNonComplianceReason: Equatable {

  // MARK: Lifecycle

  public init(values: [String: String]) {
    localizedValues = values
  }

  // MARK: Internal

  public func localized(_ preferredLanguageCodes: [UserLanguageCode] = Container.shared.preferredUserLanguageCodes()) -> String? {
    preferredLanguageCodes
      .compactMap { localizedValues[$0] }
      .first ?? localizedValues.values.first
  }

  // MARK: Private

  private let localizedValues: [String: String]
}
