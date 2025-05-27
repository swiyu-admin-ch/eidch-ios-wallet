import AVFoundation
import Foundation

// MARK: - CameraManager

public class CameraManager: NSObject, ObservableObject {

  // MARK: Public

  public let session = AVCaptureSession()

  @Published public var flashlight = TorchManager()
  @Published public var capturedObject: AVMetadataMachineReadableCodeObject?

  public func start() {
    guard
      AVCaptureDevice.authorizationStatus(for: .video) == .authorized,
      !session.isRunning
    else { return }

    qrOutput.isEnabled = true

    metadataQueue.async { [weak self] in
      self?.session.startRunning()
    }
  }

  public func stop() {
    guard session.isRunning else { return }

    metadataQueue.async { [weak self] in
      self?.session.stopRunning()
    }

    qrOutput.isEnabled = false
  }

  public func restart() {
    guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else { return }
    isMetadataOutputEnabled = true
    qrOutput.isEnabled = true
  }

  public func configure() throws {
    try configureVideoInput()
    try configureMetadataOutput()
  }

  // MARK: Internal

  enum Constant {
    public static let videoOutputSettings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)]

    public static let metadataScannerType: [AVMetadataObject.ObjectType] = [.qr]
  }

  var videoDeviceInput: AVCaptureDeviceInput?

  let metadataQueue = DispatchQueue(label: "qrreader.metadata.queue")
  let metadataOutput = AVCaptureMetadataOutput()
  var isMetadataOutputEnabled = true
  var metadataScannerType: [AVMetadataObject.ObjectType] = Constant.metadataScannerType

  // MARK: Private

  private var qrOutput = CameraQRCodeOutput()

  private func configureVideoInput() throws {
    guard let device = AVCaptureDevice.default(for: .video) else {
      session.commitConfiguration()
      throw CameraManagerError.captureDeviceNotAvailable
    }

    let videoInput = try AVCaptureDeviceInput(device: device)
    guard session.canAddInput(videoInput) else {
      session.commitConfiguration()
      throw CameraManagerError.cannotAddVideoInput
    }

    session.addInput(videoInput)
    videoDeviceInput = videoInput
  }

  private func configureMetadataOutput() throws {
    guard session.canAddOutput(metadataOutput) else { throw CameraManagerError.cannotAddMetadataOutput }
    session.addOutput(metadataOutput)

    qrOutput.delegate = self
    metadataOutput.setMetadataObjectsDelegate(qrOutput, queue: metadataQueue)
    metadataOutput.metadataObjectTypes = Constant.metadataScannerType
  }

}

// MARK: QROutputDelegate

extension CameraManager: QROutputDelegate {
  func didCapture(_ object: AVMetadataMachineReadableCodeObject) {
    capturedObject = object
  }
}

// MARK: - QROutputDelegate

protocol QROutputDelegate: AnyObject {
  func didCapture(_ object: AVMetadataMachineReadableCodeObject)
}

// MARK: - CameraQRCodeOutput

class CameraQRCodeOutput: NSObject, AVCaptureMetadataOutputObjectsDelegate {

  // MARK: Public

  public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    guard
      isEnabled,
      let metadataObject = metadataObjects.first,
      let object = metadataObject as? AVMetadataMachineReadableCodeObject,
      [.qr].contains(metadataObject.type)
    else { return }

    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      delegate?.didCapture(object)
    }
  }

  // MARK: Internal

  var isEnabled = true
  weak var delegate: QROutputDelegate?

}

// MARK: - CameraManagerError

fileprivate enum CameraManagerError: Error {
  case captureDeviceNotAvailable

  case cannotAddVideoInput
  case cannotAddVideoOutput
  case cannotAddMetadataOutput
}
