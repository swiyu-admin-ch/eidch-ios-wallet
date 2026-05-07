import BITL10n
import Foundation
import NavigatorUI
import SwiftUI

public struct ErrorView: View {

  // MARK: Lifecycle

  public init(dataset: ErrorDataset, onClose: (() -> Void)? = nil) {
    self.dataset = dataset
    self.onClose = onClose
  }

  // MARK: Public

  public var body: some View {
    InformationView2(
      contents: dataset.contents,
      actions: dataset.actions)
      .navigationBarBackButtonHidden()
      .toolbar {
        CloseButtonToolbar {
          onClose?()
          navigator.dismiss()
        }
      }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  private let dataset: ErrorDataset
  private let onClose: (() -> Void)?

}
