import BITTheming
import Factory
import NavigatorUI
import SwiftUI

struct EIDRequestErrorView: View {

  // MARK: Lifecycle

  init(dataset: ErrorDataset) {
    self.dataset = dataset
  }

  // MARK: Internal

  var body: some View {
    ErrorView(dataset: dataset, onClose: {
      coordinator.cleanup()
    })
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  @Injected(\.eidRequestFlowCoordinator) private var coordinator: EIDRequestFlowCoordinatorProtocol

  private let dataset: ErrorDataset

}
