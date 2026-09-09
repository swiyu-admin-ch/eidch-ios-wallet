// swiftlint:disable force_unwrapping force_cast

import Foundation
import Testing
@testable import BITAppInfo

struct VersionEnforcementResponseTests {

  // MARK: Internal

  @Test
  func decode_success_returnsAllProfiles() throws {
    let data = VersionEnforcement.Response.Mock.sampleData

    let config = try decoder.decode(VersionEnforcement.Response.self, from: data)

    let profiles = config.swissProfiles
    #expect(profiles.count == 10)

    let currentProfiles = profiles.filter { $0.status == .current }
    #expect(currentProfiles.count == SwissProfile.ProfileType.allCases.count)
    #expect(Set(currentProfiles.map(\.type)) == Set(SwissProfile.ProfileType.allCases))
    #expect(currentProfiles.allSatisfy { $0.version == "1.0.0" })

    let deprecatedProfile = try #require(profiles.first { $0.status == .deprecated })
    #expect(deprecatedProfile.type == .anchor)
    #expect(deprecatedProfile.version == "0.1.0")

    let sunsetProfile = try #require(profiles.first { $0.status == .sunset })
    #expect(sunsetProfile.type == .issuance)
    #expect(sunsetProfile.version == "0.2.0")

    let endOfLifeProfile = try #require(profiles.first { $0.status == .endOfLife })
    #expect(endOfLifeProfile.type == .verifiableCredential)
    #expect(endOfLifeProfile.version == "0.3.0")
  }

  // MARK: Private

  private let decoder = JSONDecoder(dateDecodingStrategy: .formatted(DateFormatter(format: "yyyy-MM-dd")))
}
