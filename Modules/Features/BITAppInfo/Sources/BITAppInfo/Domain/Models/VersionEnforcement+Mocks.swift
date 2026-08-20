#if DEBUG
// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try
import Foundation
@testable import BITCore

extension VersionEnforcement: Mockable {
  public struct Mock {

    static let forced = make(type: .forced)
    static let optional = make(type: .optional, title: "Optional Update")
    static let outdatedOsVersion = make(type: .outdatedOsVersion, title: "Unsupported OS")
    static let blacklistedDevice = make(type: .blacklistedDevice, title: "Unauthorized Device")
    static let noDisplay = make(type: .optional, title: nil, body: nil)

    private static func make(
      type: VersionEnforcementType = .forced,
      title: String? = "Update Required",
      body: String? = "Some body")
      -> VersionEnforcement
    {
      VersionEnforcement(type: type, messages: .Mock.make(title: title, body: body))
    }
  }
}

extension [VersionEnforcement.Message] {
  enum Mock {

    static func make(title: String? = "Update Required", body: String? = "Some body") -> [VersionEnforcement.Message] {
      if let title, let body {
        [VersionEnforcement.Message(title: title, body: body, locale: "en-US")]
      } else {
        []
      }
    }
  }
}

extension VersionEnforcement.Response {
  enum Mock {

    static let sampleData: Data = Mocker.getData(fromFile: "version-enforcement-response", bundle: .module) ?? Data()

    static func make(
      blacklistedDevice: String? = nil,
      minimumOsVersion: String = "16.0",
      defaultReleaseSupportDays: Int = 90,
      versions: [VersionEnforcement.Response.Version] = [])
      -> VersionEnforcement.Response
    {
      let deviceBlacklist: [String] = if let blacklistedDevice { [blacklistedDevice] } else { [] }

      return VersionEnforcement.Response(
        appBundleId: UUID().uuidString,
        defaultReleaseSupportDays: defaultReleaseSupportDays,
        deviceBlacklist: deviceBlacklist,
        minimumOsVersion: minimumOsVersion,
        platform: "ios",
        versions: versions)
    }

    static func forced(version: BITAppInfo.Version) -> VersionEnforcement.Response {
      make(versions: [
        .Mock.make(updateType: .forced, version: version),
      ])
    }

    static func optionalSupport(expired: Bool, currentDate: Date = Date(), version: BITAppInfo.Version) -> VersionEnforcement.Response {
      make(versions: [
        .Mock.make(
          supportGuaranteedUntil: currentDate.addingTimeInterval(expired ? -100 : 100),
          updateType: .optional,
          version: version),
      ])
    }

    static func optionalLifetime(expired: Bool, currentDate: Date = Date(), releaseSupportDays: Int = 30, version: BITAppInfo.Version) -> VersionEnforcement.Response {
      make(
        defaultReleaseSupportDays: releaseSupportDays,
        versions: [
          .Mock.make(
            releaseDate: Calendar.current
              .date(byAdding: .day, value: -releaseSupportDays, to: currentDate)!
              .addingTimeInterval(expired ? -100 : 100),
            supportGuaranteedUntil: nil,
            updateType: .optional,
            version: version),
        ])
    }
  }
}

extension VersionEnforcement.Response.Version {
  enum Mock {
    static func make(
      releaseDate: Date = Date(),
      supportGuaranteedUntil: Date? = Date(),
      updateType: VersionEnforcement.Response.UpdateType = .forced,
      version: BITAppInfo.Version = BITAppInfo.Version("1.13.1"))
      -> VersionEnforcement.Response.Version
    {
      VersionEnforcement.Response.Version(
        message: .Mock.make(),
        releaseDate: releaseDate,
        supportGuaranteedUntil: supportGuaranteedUntil,
        updateType: updateType,
        version: version.rawValue)
    }
  }
}
#endif
