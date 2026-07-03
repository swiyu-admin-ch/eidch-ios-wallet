import BITClaimsPathPointer
import Foundation

// MARK: - SdJWTDisclosure

public struct SdJWTDisclosure: Equatable, Hashable {

  public let paths: [ClaimsPathPointer]
  public let disclosure: String
}
