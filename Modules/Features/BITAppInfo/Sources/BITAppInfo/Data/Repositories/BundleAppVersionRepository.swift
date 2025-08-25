import Foundation
import Spyable

// MARK: - AppVersionRepositoryProtocol

@Spyable
public protocol AppVersionRepositoryProtocol {
  func getVersion() throws -> String
  func getBuildNumber() throws -> Int
}

// MARK: - BundleAppVersionRepository

struct BundleAppVersionRepository: AppVersionRepositoryProtocol {
  private let appVersionKey = "CFBundleShortVersionString"
  private let buildNumberKey = "CFBundleVersion"

  func getVersion() throws -> String {
    guard let version = Bundle.main.infoDictionary?[appVersionKey] as? String else { throw AppVersionError.notFound }
    return version
  }

  func getBuildNumber() throws -> Int {
    guard let buildNumber = Bundle.main.infoDictionary?[buildNumberKey] as? String else { throw AppVersionError.notFound }
    return Int(buildNumber) ?? -1
  }

}

// MARK: - AppVersionError

enum AppVersionError: Error {
  case notFound
}
