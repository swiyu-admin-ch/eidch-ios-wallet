// swiftlint: disable implicitly_unwrapped_optional force_try
#if DEBUG
import Foundation
@testable import BITTestingCore

extension NonCompliantActorsResponse: Mockable {
  public struct Mock {
    public static let `default` = NonCompliantActorsResponse(nonCompliantActors: [
      NonCompliantActor(reason: ["de": "Reason de", "en": "Reason en"], did: "did:example:verifier1"),
      NonCompliantActor(reason: ["de": "Reason de", "en": "Reason en"], did: "did:example:verifier2"),
    ])
    public static let empty = NonCompliantActorsResponse(nonCompliantActors: [])

    public static var defaultData: Data { try! JSONEncoder().encode(Mock.default) }
    public static var emptyData: Data { try! JSONEncoder().encode(Mock.empty) }
  }
}
#endif
