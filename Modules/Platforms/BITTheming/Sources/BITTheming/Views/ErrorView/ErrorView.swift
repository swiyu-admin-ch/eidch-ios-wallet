import BITL10n
import Foundation
import NavigatorUI
import SwiftUI

public struct ErrorView: View {

  // MARK: Lifecycle

  public init(dataset: ErrorDataset) {
    self.dataset = dataset
  }

  // MARK: Public

  public var body: some View {
    InformationView2(
      image: ThemingAssets.closeCircle.swiftUIImage,
      contents: dataset.contents,
      actions: dataset.actions)
      .navigationBarBackButtonHidden(true)
      .toolbar {
        CloseButtonToolbar {
          navigator.dismiss()
        }
      }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  private let dataset: ErrorDataset

}
