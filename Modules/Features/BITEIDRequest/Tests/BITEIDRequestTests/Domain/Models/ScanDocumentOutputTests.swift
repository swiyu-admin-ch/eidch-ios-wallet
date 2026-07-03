import Testing
import UIKit
@testable import BITAVWrapper
@testable import BITEIDRequest
@testable import BITEIDRequestShared

struct ScanDocumentOutputTests {

  @Test
  func initialization() throws {
    let scanningOrientiations: [ScanningState: UIDeviceOrientation] = [.recto: .portrait, .verso: .landscapeLeft]
    let documentOutput = try ScanDocumentOutput(.Mock.sample, scanningOrientiations: scanningOrientiations, identityType: .passport)

    #expect(documentOutput.identityType == .passport)
    #expect(documentOutput.files.count == 3)
    #expect(documentOutput.scanningOrientiations == scanningOrientiations)
  }
}
