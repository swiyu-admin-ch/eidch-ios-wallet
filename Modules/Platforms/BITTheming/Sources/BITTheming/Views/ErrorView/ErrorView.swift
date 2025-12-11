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
    InformationView(
      image: ThemingAssets.closeCircle.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: dataset.primary,
          secondary: dataset.secondary,
          tertiary: dataset.tertiary,
          tertiaryAction: dataset.tertiaryAction)
      },
      footer: { footerView })
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

  @ViewBuilder
  private var footerView: some View {
    ButtonSheet {
      if let primaryAction = dataset.primaryAction, let primaryActionLabel = dataset.primaryActionLabel {
        VStack(spacing: .x4) {
          Button(action: {
            navigator.pop()
            primaryAction()
          }) {
            Text(primaryActionLabel)
              .multilineTextAlignment(.leading)
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.primary)
          .controlSize(.large)
          .accessibilityLabel(primaryActionLabel)
        }

        if let secondaryAction = dataset.secondaryAction, let secondaryActionLabel = dataset.secondaryActionLabel {
          Button(action: { secondaryAction() }) {
            Text(secondaryActionLabel)
              .multilineTextAlignment(.leading)
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.secondary)
          .controlSize(.large)
          .accessibilityLabel(secondaryActionLabel)
        }
      }
    }
  }

}
