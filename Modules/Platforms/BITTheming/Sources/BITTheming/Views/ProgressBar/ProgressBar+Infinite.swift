import SwiftUI

// MARK: - InfiniteProgressBar

public struct InfiniteProgressBar: View {

  // MARK: Lifecycle

  public init(image: Image) {
    self.image = image
  }

  // MARK: Public

  public var body: some View {
    ProgressBar(image: image, sequence: .infiniteRandomSequence)
  }

  // MARK: Internal

  let image: Image

}
