#if DEBUG
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
      releaseDate: Date = Date(),
      defaultReleaseSupportDays: Int = 90,
      supportGuaranteedUntil: Date? = Date(),
      updateType: UpdateType = .forced,
      version: BITAppInfo.Version = BITAppInfo.Version("1.13.1"))
      -> VersionEnforcement.Response
    {
      let deviceBlacklist: [String] = if let blacklistedDevice { [blacklistedDevice] } else { [] }

      return VersionEnforcement.Response(
        appBundleId: UUID().uuidString,
        defaultReleaseSupportDays: defaultReleaseSupportDays,
        deviceBlacklist: deviceBlacklist,
        minimumOsVersion: minimumOsVersion,
        platform: "ios",
        versions: [
          VersionEnforcement.Response
            .Version(
              message: .Mock.make(),
              releaseDate: releaseDate,
              supportGuaranteedUntil: supportGuaranteedUntil,
              updateType: updateType,
              version: version.rawValue),
        ])
    }
  }
}
#endif
