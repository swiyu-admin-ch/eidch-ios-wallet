import Factory
import SwiftUI

@MainActor
@Observable
final class ScanDocumentImageOverviewViewModel {

  // MARK: Lifecycle

  init(image: ScanResultEntryImage) {
    self.image = image
  }

  // MARK: Internal

  let image: ScanResultEntryImage
  private(set) var imageRotation: Angle?

  func rotateImageIfNeeded() {
    imageRotation = image.uiOrientation?.isPortrait == true ? .degrees(-90) : nil
  }
}
