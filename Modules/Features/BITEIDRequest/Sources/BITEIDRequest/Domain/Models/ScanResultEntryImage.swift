import Foundation
import UIKit

public struct ScanResultEntryImage: Hashable {
  let key: String
  let value: Data
  let side: ScanningState
  let uiOrientation: UIDeviceOrientation?
  let accessibilityLabel: String
}
