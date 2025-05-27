import AudioToolbox
import AVFoundation
import SwiftUI

// MARK: - CameraPreview

public struct CameraPreview: UIViewRepresentable {

  // MARK: Lifecycle

  public init(session: AVCaptureSession, object: AVMetadataMachineReadableCodeObject?, _ didMoveFocusArea: @escaping (AVMetadataMachineReadableCodeObject) -> Void) {
    self.session = session
    self.object = object
    self.didMoveFocusArea = didMoveFocusArea
  }

  // MARK: Public

  public func updateUIView(_ uiView: CameraPreviewView, context: Context) {
    guard let object else { return }
    uiView.didReceive(object)
  }

  public func makeUIView(context: Context) -> CameraPreviewView {
    let view = CameraPreviewView()
    view.setupPreviewLayer(session)
    view.didMoveFocusArea = didMoveFocusArea
    return view
  }

  // MARK: Internal

  let session: AVCaptureSession
  var didMoveFocusArea: (AVMetadataMachineReadableCodeObject) -> Void
  var object: AVMetadataMachineReadableCodeObject?

}

// MARK: - CameraPreviewView

public class CameraPreviewView: UIView {

  // MARK: Lifecycle

  public override init(frame: CGRect) {
    super.init(frame: frame)
    configureTimer()
    observeOrientationChanges()
  }

  public required init?(coder: NSCoder) {
    fatalError("Not implemented...")
  }

  deinit {
    NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
  }

  // MARK: Public

  override public class var layerClass: AnyClass {
    AVCaptureVideoPreviewLayer.self
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    adjustVideoOrientation()
    if focusAreaShape.path == nil || boundsHaveChanged() {
      focusAreaShape.resetPositionToCenter(of: self)
    }
  }

  // MARK: Internal

  var didMoveFocusArea: ((AVMetadataMachineReadableCodeObject) -> Void)?

  var videoPreviewLayer: AVCaptureVideoPreviewLayer {
    // swiftlint: disable all
    layer as! AVCaptureVideoPreviewLayer
    // swiftlint: enable all
  }

  func didReceive(_ object: AVMetadataMachineReadableCodeObject) {
    DispatchQueue.main.async { [weak self] in
      self?.lastScannedItemDate = Date()
      self?.moveFocusArea(using: object)
    }
  }

  func setupPreviewLayer(_ session: AVCaptureSession) {
    videoPreviewLayer.session = session
    videoPreviewLayer.videoGravity = .resizeAspectFill
    backgroundColor = .black
  }

  // MARK: Private

  private typealias Triangle = (a: CGFloat, b: CGFloat, c: CGFloat)

  private static let scannerTimeoutInterval: TimeInterval = 0.5

  private static let focusAreaDefaultSize = 200.0
  private static let focusAreaPadding: CGFloat = 16

  private var lastScannedItemDate: Date?
  private var scannerTimer: Timer?

  private lazy var focusAreaShape: FocusAreaShapeLayer = {
    let shapeLayer = FocusAreaShapeLayer()
    layer.addSublayer(shapeLayer)
    return shapeLayer
  }()

  private var lastBounds = CGRect.zero

  private func adjustVideoOrientation() {
    guard
      let previewLayerConnection = videoPreviewLayer.connection,
      let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
      let orientation = keyWindow.windowScene?.interfaceOrientation,
      let videoOrientation = orientation.videoOrientation
    else {
      return
    }

    previewLayerConnection.videoOrientation = videoOrientation
    videoPreviewLayer.frame = bounds
  }

  private func moveFocusArea(using object: AVMetadataMachineReadableCodeObject) {
    assert(Thread.isMainThread)

    guard !object.corners.isEmpty else { return }

    guard let transformedObject = videoPreviewLayer.transformedMetadataObject(for: object) as? AVMetadataMachineReadableCodeObject else { return }
    let coordinates = sortCorners(transformedObject.corners)
    focusAreaShape.move(to: coordinates)
    didMoveFocusArea?(object)
  }

  private func configureTimer() {
    scannerTimer = Timer.scheduledTimer(withTimeInterval: Self.scannerTimeoutInterval, repeats: true) { [weak self] _ in
      self?.resetFocusAreaIfNeeeded()
    }
  }

  private func observeOrientationChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(handleOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
  }

  @objc
  private func handleOrientationChange() {
    adjustVideoOrientation()
    setNeedsLayout()
  }

  private func resetFocusAreaIfNeeeded() {
    guard let lastScannedItemDate, Date().timeIntervalSince(lastScannedItemDate) > Self.scannerTimeoutInterval else { return }
    self.lastScannedItemDate = nil
    focusAreaShape.resetPositionToCenter(of: self)
  }

  private func sortCorners(_ corners: [CGPoint]) -> [CGPoint] {
    guard corners.count == 4 else { return corners }

    let center = CGPoint(
      x: (corners[0].x + corners[1].x + corners[2].x + corners[3].x) / 4,
      y: (corners[0].y + corners[1].y + corners[2].y + corners[3].y) / 4)

    let sortedCorners = corners.sorted { corner1, corner2 in
      let angle1 = atan2(corner1.y - center.y, corner1.x - center.x)
      let angle2 = atan2(corner2.y - center.y, corner2.x - center.x)
      return angle1 < angle2
    }

    return sortedCorners
  }

  private func boundsHaveChanged() -> Bool {
    defer { lastBounds = bounds }
    return lastBounds != bounds
  }

}

extension UIInterfaceOrientation {
  fileprivate var videoOrientation: AVCaptureVideoOrientation? {
    switch self {
    case .portraitUpsideDown: .portraitUpsideDown
    case .landscapeRight: .landscapeRight
    case .landscapeLeft: .landscapeLeft
    case .portrait: .portrait
    default: nil
    }
  }
}
