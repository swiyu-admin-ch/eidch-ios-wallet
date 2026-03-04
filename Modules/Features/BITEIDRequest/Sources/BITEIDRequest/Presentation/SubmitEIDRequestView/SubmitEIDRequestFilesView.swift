import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

struct SubmitEIDRequestView: View {

  // MARK: Internal

  var body: some View {
    InformationView2(
      contents: [
        .heroCard(progressView),
        .title(L10n.tkEidRequestSubmitDocumentsPrimary),
        .body(L10n.tkEidRequestSubmitDocumentsSecondary),
      ])
      .navigationBarBackButtonHidden()
      .task {
        await viewModel.submit()
      }
      .navigate(to: $viewModel.destination)
      .toolbar(.visible)
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  @InjectedObject(\.submitEIDRequestFilesViewModel) private var viewModel

  private func progressView() -> some View {
    ProgressView(
      value: viewModel.overallProgress,
      label: {},
      currentValueLabel: {
        Text(viewModel.overallProgress.formatted(.percent.precision(.fractionLength(0))))
          .foregroundStyle(ThemingAssets.Brand.Accent.purple.swiftUIColor)
      })
      .progressViewStyle(.linearGradient)
      .frame(width: 240)
  }

}
