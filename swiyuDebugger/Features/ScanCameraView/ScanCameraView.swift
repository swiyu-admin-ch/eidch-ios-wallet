import BITInvitation
import BITL10n
import BITPresentation
import BITQRCode
import BITTheming
import SwiftUI

struct ScanCameraView: View {

  // MARK: Lifecycle

  init() {
    let router = ScanCameraRouter()
    _router = StateObject(wrappedValue: router)
    _viewModel = StateObject(wrappedValue: CameraViewModel(router: router))
  }

  // MARK: Internal

  var body: some View {
    NavigationStack(path: $path) {
      VStack {
        scannerView()
      }
      .cameraPermission()
      .toolbar { toolbar }
      .task {
        await viewModel.onAppear()
      }
      .onAppear {
        router.onClose = { dismiss() }
      }
      .onChange(of: router.route?.id) { _ in
        guard let route = router.route else { return }
        path.append(route)
        router.route = nil
      }
      .onChange(of: currentErrorMessage) { message in
        guard let message, message != lastErrorMessage else { return }
        lastErrorMessage = message
        if let error = viewModel.currentError {
          path.append(ScanCameraErrorRoute(error: error))
        }
      }
      .navigationDestination(for: ScanCameraRoute.self) { route in
        switch route.destination {
        case .credential(let credential, let trustInformation):
          ScanResultView(
            mode: .credential(credential, trustInformation),
            invitationURL: viewModel.currentInvitationURL,
            onClose: { dismiss() })
        case .presentation(let context):
          ScanResultView(
            mode: .presentation(context),
            invitationURL: viewModel.currentInvitationURL,
            onClose: { dismiss() })
        }
      }
      .navigationDestination(for: ScanCameraErrorRoute.self) { route in
        ScanResultView(
          mode: .error(route.error),
          invitationURL: viewModel.currentInvitationURL,
          onClose: { dismiss() })
      }
    }
  }

  // MARK: Private

  private struct ScanCameraError: Error {
    let message: String
  }

  @Environment(\.dismiss) private var dismiss
  @StateObject private var router: ScanCameraRouter
  @StateObject private var viewModel: CameraViewModel
  @State private var path = NavigationPath()
  @State private var lastErrorMessage: String?

  @ToolbarContentBuilder
  private var toolbar: some ToolbarContent {
    ToolbarItem(placement: .navigationBarTrailing) {
      Button(role: .close) {
        dismiss()
      }
    }
  }

  private var currentErrorMessage: String? {
    guard let error = viewModel.currentError else { return nil }
    return String(reflecting: error)
  }

  private func scannerView() -> some View {
    ZStack {
      CameraPreview(session: viewModel.session, object: viewModel.cameraManager.capturedObject, viewModel.didMoveFocusArea(to:))
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
