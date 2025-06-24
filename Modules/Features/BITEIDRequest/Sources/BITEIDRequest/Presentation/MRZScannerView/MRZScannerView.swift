import BITTheming
import Factory
import SwiftUI

struct MRZScannerView: View {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    _viewModel = StateObject(wrappedValue: Container.shared.mrzScannerViewModel(router))
  }

  // MARK: Internal

  var body: some View {
    ZStack(alignment: .center) {
      List {
        ForEach(MRZData.Mock.array) { mrzData in
          AsyncButton(
            action: { await viewModel.submit(mrzData.payload) },
            actionOptions: [.showProgressView, .disableButton],
            label: {
              Text(mrzData.displayName)
            })
            .buttonStyle(.filledPrimary)
            .controlSize(.large)
            .frame(maxWidth: .infinity, alignment: .center)
            .listRowSeparator(.hidden)
            .listStyle(.plain)
        }
      }
      .listStyle(.plain)
      .padding(.bottom, .x12)

      VStack {
        Spacer()
        Button(action: viewModel.close) {
          Text("Cancel")
        }
        .buttonStyle(.bezeledLight)
        .controlSize(.large)
      }
    }
    .alert(isPresented: $viewModel.isErrorPresented) {
      Alert(title: Text("Error"), message: Text(viewModel.errorDescription ?? "Unknown error"), dismissButton: .default(Text("OK"), action: viewModel.resetError))
    }
    .navigationBarBackButtonHidden(true)
  }

  // MARK: Private

  @StateObject private var viewModel: MRZScannerViewModel
}

#Preview {
  MRZScannerView(router: EIDRequestRouter())
}
