import AVFoundation
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
        Camera(
          session: viewModel.cameraManager.session,
          capturedObject: viewModel.cameraManager.capturedObject,
          isLoading: viewModel.isLoading,
          didMoveFocusArea: viewModel.didMoveFocusArea(to:))
      }
      .cameraPermission { state in
        Task {
          await viewModel.onCameraPermissionChange(state)
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
}

// MARK: - Camera

private struct Camera: View {

  let session: AVCaptureSession
  let capturedObject: AVMetadataMachineReadableCodeObject?
  let isLoading: Bool
  let didMoveFocusArea: (AVMetadataMachineReadableCodeObject) -> Void

  var body: some View {
    ZStack {
      CameraPreview(session: session, object: capturedObject, didMoveFocusArea)
        .clipShape(RoundedCorner(radius: .x6, corners: [.topLeft, .topRight]))
        .padding(.top, .x2)
        .ignoresSafeArea(edges: [.bottom])
        .accessibilityLabel(L10n.tkQrscannerScanningTitle)
    }
    .overlay {
      if isLoading {
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
