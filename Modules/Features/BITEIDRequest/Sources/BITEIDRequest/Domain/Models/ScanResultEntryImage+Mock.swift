#if DEBUG
// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try
import Foundation
import UIKit

extension ScanResultEntryImage {
  enum Mock {
    static let croppedIDScanRecto = make(fileName: "firstImage", side: .recto)
    static let fullframeIDScanRecto = make(fileName: "fullFrameFirstPage", side: .recto)
    static let croppedIDScanVerso = make(fileName: "secondImage", side: .verso)
    static let fullframeIDScanVerso = make(fileName: "fullFrameSecondPage", side: .verso)

    static func make(
      key: String = "key",
      fileName: String = "sample",
      side: ScanningState = .recto,
      uiOrientation: UIDeviceOrientation = .portrait)
      -> ScanResultEntryImage
    {
      ScanResultEntryImage(
        key: key,
        value: fileName.data(using: .utf8)!,
        side: side,
        uiOrientation: uiOrientation,
        accessibilityLabel: "accessibilityLabel")
    }
  }
}
#endif
