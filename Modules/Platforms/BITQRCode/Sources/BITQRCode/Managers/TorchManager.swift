import AVFoundation
import Foundation
import SwiftUI

// MARK: - TorchError

public enum TorchError: Error, LocalizedError {
  case torchUnavailable
  case configurationFailed(Error)
  case unknown

  public var errorDescription: String? {
    switch self {
    case .torchUnavailable:
      "Torch is not available on this device."
    case .configurationFailed(let underlyingError):
      "Failed to configure the torch: \(underlyingError.localizedDescription)"
    case .unknown:
      "An unknown error occurred."
    }
  }
}

// MARK: - TorchManager

public class TorchManager: ObservableObject {

  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  @Published public private(set) var torchError: TorchError?
  @Published public private(set) var isEnabled = AVCaptureDevice.FlashMode.off

  public func turnOff() {
    do {
      try toggleTorchMode(force: .off)
    } catch {
      handleError(error)
    }
  }

  public func turnOn() {
    do {
      try toggleTorchMode(force: .on)
    } catch {
      handleError(error)
    }
  }

  public func toggle() {
    do {
      if isTorchAvailable() {
        try toggleTorchMode()
        torchError = nil
      } else {
        torchError = .torchUnavailable
      }
    } catch {
      handleError(error)
    }
  }

  // MARK: Private

  private func isTorchAvailable() -> Bool {
    guard let device = AVCaptureDevice.default(for: .video) else { return false }
    return device.hasTorch
  }

  private func toggleTorchMode(force mode: AVCaptureDevice.FlashMode? = nil) throws {
    guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }

    try device.lockForConfiguration()

    if let mode {
      isEnabled = mode
    } else {
      isEnabled = isEnabled == .off ? .on : .off
    }

    if isEnabled == .on {
      try device.setTorchModeOn(level: 1.0)
    } else {
      device.torchMode = .off
    }

    device.unlockForConfiguration()
  }

  private func handleError(_ error: Error) {
    if let torchError = error as? TorchError {
      self.torchError = torchError
    } else {
      torchError = .configurationFailed(error)
    }
  }
}
