import BITSdJWT
import Foundation

// MARK: - VcSdJwtTokenStatusList + AnyStatus

extension VcSdJwtTokenStatusList: AnyStatus {

  public var type: AnyStatusType {
    AnyStatusType.tokenStatusList
  }

}
