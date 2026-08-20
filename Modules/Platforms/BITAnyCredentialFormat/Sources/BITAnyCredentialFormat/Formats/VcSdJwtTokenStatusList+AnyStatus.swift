import BITSdJWT
import Foundation

// MARK: - VcSdJwtTokenStatusList + AnyStatus

extension VcSdJwtTokenStatus: AnyStatus {

  public var type: AnyStatusType {
    AnyStatusType.tokenStatusList
  }

}
