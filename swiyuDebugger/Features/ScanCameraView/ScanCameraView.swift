import BITCredential
import BITCredentialShared
import BITInvitation
import BITL10n
import BITPresentation
import BITQRCode
import BITTheming
import NavigatorUI
import SwiftUI

// MARK: - ScanCameraView

struct ScanCameraView: View {

  // MARK: Lifecycle

  init(url: URL? = nil) {
    if let url {
      _viewModel = State(initialValue: CameraViewModel(url: url))
    } else {
      _viewModel = State(initialValue: CameraViewModel())
    }
  }

  // MARK: Internal

  var body: some View {
    ManagedNavigationStack {
      VStack {
        scannerView()
      }
      .cameraPermission { state in
        Task {
          if state == .authorized {
            await viewModel.onAppear()
          }
        }
      }
      .toolbar { toolbar }
      .navigate(to: $destination)
      .navigationBarBackButtonHidden()
      .onChange(of: viewModel.destination) { _, destinationValue in
        guard let destinationValue else { return }
        destination = ScanCameraDestination(
          invitationDestination: destinationValue,
          invitationURL: viewModel.currentInvitationURL)
      }
      .onChange(of: currentErrorMessage) { _, message in
        guard let message, message != lastErrorMessage else { return }
        lastErrorMessage = message
        if let error = viewModel.currentError {
          destination = .error(error, viewModel.currentInvitationURL)
        }
      }
    }
  }

  // MARK: Private

  @Environment(\.dismiss) private var dismiss
  @Environment(\.navigator) private var navigator
  @State private var viewModel = CameraViewModel()
  @State private var destination: ScanCameraDestination?
  @State private var lastErrorMessage: String?

  @ToolbarContentBuilder
  private var toolbar: some ToolbarContent {
    ToolbarItem(placement: .navigationBarTrailing) {
      Button(action: { dismiss() }, label: {
        Image(systemName: "xmark")
      })
      .accessibilityLabel(L10n.tkGlobalClose)
    }
  }

  private var currentErrorMessage: String? {
    guard let error = viewModel.currentError else { return nil }
    return String(reflecting: error)
  }

  private func scannerView() -> some View {
    ZStack {
      CameraPreview(session: viewModel.cameraManager.session, object: viewModel.cameraManager.capturedObject, viewModel.didMoveFocusArea(to:))
        .clipShape(RoundedCorner(radius: .x6, corners: [.topLeft, .topRight]))
        .padding(.top, .x2)
        .ignoresSafeArea(edges: [.bottom])
        .accessibilityLabel(L10n.tkQrscannerScanningTitle)
    }
    .overlay {
      if viewModel.isLoading {
        Rectangle()
          .fill(.ultraThinMaterial)
          .clipShape(RoundedCorner(radius: .x6, corners: [.topLeft, .topRight]))
          .ignoresSafeArea(edges: [.bottom])
          .overlay {
            ProgressView()
              .tint(.white)
              .controlSize(.large)
          }
      }
    }
  }
}
