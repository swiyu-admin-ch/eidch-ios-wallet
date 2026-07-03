import Factory
import Foundation
import SwiftUI
import Testing
@testable import BITEIDRequest

@MainActor
@Suite(.serialized)
struct ScanDocumentImageOverviewViewModelTests {

  // MARK: Lifecycle

  init() {
    viewModel = ScanDocumentImageOverviewViewModel(image: Self.mockScannedImage)
  }

  // MARK: Internal

  @Test
  func initialized() {
    #expect(viewModel.image == Self.mockScannedImage)
    #expect(viewModel.imageRotation == nil)
  }

  @Test(arguments: [
    (UIDeviceOrientation.portrait, Angle.degrees(-90)),
    (UIDeviceOrientation.portraitUpsideDown, Angle.degrees(-90)),
    (UIDeviceOrientation.landscapeLeft, nil),
    (UIDeviceOrientation.landscapeRight, nil),
  ])
  mutating func rotateImageIfNeeded(when uiOrientation: UIDeviceOrientation, expect expectedAngle: Angle?) {
    viewModel = ScanDocumentImageOverviewViewModel(image: .Mock.make(uiOrientation: uiOrientation))

    viewModel.rotateImageIfNeeded()

    #expect(viewModel.imageRotation == expectedAngle)
  }

  // MARK: Private

  private static let mockScannedImage = ScanResultEntryImage.Mock.make()

  private var viewModel: ScanDocumentImageOverviewViewModel

}
