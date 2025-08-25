import Foundation
import Spyable

// MARK: - AppIdentifierRepositoryProtocol

@Spyable
public protocol AppIdentifierRepositoryProtocol {
  func get() throws -> String
}

// MARK: - AppIdentifierRepository

struct AppIdentifierRepository: AppIdentifierRepositoryProtocol {
  func get() throws -> String {
    guard let identifier = Bundle.main.infoDictionary?[Self.appIdentifierKey] as? String else {
      throw AppIdentifierRepositoryError.notFound
    }

    return identifier
  }

  private static let appIdentifierKey = "CFBundleIdentifier"
}

// MARK: - AppIdentifierRepositoryError

enum AppIdentifierRepositoryError: Error {
  case notFound
}
