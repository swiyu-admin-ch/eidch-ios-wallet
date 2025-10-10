// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Foundation
import pxlbeam_onboard
import UIKit
@testable import BITAVWrapper

// MARK: - AVBeamProtocolSpy

public class AVBeamProtocolSpy: AVBeamProtocol {

  // MARK: Lifecycle

  // MARK: - Initialization

  public required init() {}

  // MARK: Public

  // MARK: - State Management

  public var state = AVBeamState.notInitialized

  // MARK: - Delegates

  public weak var messageDelegate: AVBeamMessageDelegate?
  public weak var scanDocumentDelegate: AVBeamScanDocumentDelegate?
  public weak var recordDocumentDelegate: AVBeamRecordDocumentDelegate?
  public weak var captureFaceDelegate: AVBeamCaptureFaceDelegate?
  public weak var nfcDelegate: AVBeamNfcDelegate?

  // MARK: - Method Call Tracking Properties

  public var initializeUsingCalled = false
  public var initializeUsingCallsCount = 0
  public var initializeUsingReceivedConfig: AVBeamInitConfig?
  public var initializeUsingReceivedInvocations = [AVBeamInitConfig]()
  public var initializeUsingThrowableError: Error?

  public var shutdownCalled = false
  public var shutdownCallsCount = 0

  public var getGLViewCalled = false
  public var getGLViewCallsCount = 0
  public var getGLViewReceivedArguments: (width: Int, height: Int)?
  public var getGLViewReceivedInvocations = [(width: Int, height: Int)]()
  public var getGLViewReturnValue = UIView()

  public var startCameraCalled = false
  public var startCameraCallsCount = 0
  public var startCameraThrowableError: Error?

  public var stopCameraCalled = false
  public var stopCameraCallsCount = 0
  public var stopCameraThrowableError: Error?

  public var startScanDocumentConfigCalled = false
  public var startScanDocumentConfigCallsCount = 0
  public var startScanDocumentConfigReceivedConfig: AVBeamScanDocumentConfig?
  public var startScanDocumentConfigReceivedInvocations = [AVBeamScanDocumentConfig]()
  public var startScanDocumentConfigThrowableError: Error?

  public var stopScanDocumentCalled = false
  public var stopScanDocumentCallsCount = 0

  public var startRecordDocumentConfigCalled = false
  public var startRecordDocumentConfigCallsCount = 0
  public var startRecordDocumentConfigReceivedConfig: AVBeamRecordDocumentConfig?
  public var startRecordDocumentConfigReceivedInvocations = [AVBeamRecordDocumentConfig]()
  public var startRecordDocumentConfigThrowableError: Error?

  public var stopRecordDocumentCalled = false
  public var stopRecordDocumentCallsCount = 0

  public var startCaptureFaceConfigCalled = false
  public var startCaptureFaceConfigCallsCount = 0
  public var startCaptureFaceConfigReceivedConfig: AVBeamCaptureFaceConfig?
  public var startCaptureFaceConfigReceivedInvocations = [AVBeamCaptureFaceConfig]()
  public var startCaptureFaceConfigThrowableError: Error?

  public var stopCaptureFaceCalled = false
  public var stopCaptureFaceCallsCount = 0

  public var startNfcScanConfigCalled = false
  public var startNfcScanConfigCallsCount = 0
  public var startNfcScanConfigReceivedConfig: AVBeamScanNfcConfig?
  public var startNfcScanConfigReceivedInvocations = [AVBeamScanNfcConfig]()
  public var startNfcScanConfigThrowableError: Error?

  public var stopNfcScanCalled = false
  public var stopNfcScanCallsCount = 0

  // MARK: - Method Implementations

  public func initialize(using config: AVBeamInitConfig) throws {
    initializeUsingCalled = true
    initializeUsingCallsCount += 1
    initializeUsingReceivedConfig = config
    initializeUsingReceivedInvocations.append(config)

    if let error = initializeUsingThrowableError {
      throw error
    }

    // Simulate successful initialization
    state = .initialized

    // Simulate async notification
    DispatchQueue.main.async { [weak self] in
      self?.messageDelegate?.didReceiveNotification(notification: .initialized)
    }
  }

  public func shutdown() {
    shutdownCalled = true
    shutdownCallsCount += 1
    state = .notInitialized
  }

  public func getGLView(width: Int, height: Int) -> UIView {
    getGLViewCalled = true
    getGLViewCallsCount += 1
    getGLViewReceivedArguments = (width: width, height: height)
    getGLViewReceivedInvocations.append((width: width, height: height))
    return getGLViewReturnValue
  }

  public func startCamera() throws {
    startCameraCalled = true
    startCameraCallsCount += 1

    if let error = startCameraThrowableError {
      throw error
    }
  }

  public func stopCamera() throws {
    stopCameraCalled = true
    stopCameraCallsCount += 1

    if let error = stopCameraThrowableError {
      throw error
    }
  }

  public func startScanDocument(config: AVBeamScanDocumentConfig) throws {
    startScanDocumentConfigCalled = true
    startScanDocumentConfigCallsCount += 1
    startScanDocumentConfigReceivedConfig = config
    startScanDocumentConfigReceivedInvocations.append(config)

    if let error = startScanDocumentConfigThrowableError {
      throw error
    }
  }

  public func stopScanDocument() {
    stopScanDocumentCalled = true
    stopScanDocumentCallsCount += 1

    // Simulate stopping notification
    DispatchQueue.main.async { [weak self] in
      self?.messageDelegate?.didReceiveNotification(notification: .idRecognitionStopped)
    }
  }

  public func startRecordDocument(config: AVBeamRecordDocumentConfig) throws {
    startRecordDocumentConfigCalled = true
    startRecordDocumentConfigCallsCount += 1
    startRecordDocumentConfigReceivedConfig = config
    startRecordDocumentConfigReceivedInvocations.append(config)

    if let error = startRecordDocumentConfigThrowableError {
      throw error
    }
  }

  public func stopRecordDocument() {
    stopRecordDocumentCalled = true
    stopRecordDocumentCallsCount += 1

    // Simulate stopping notification
    DispatchQueue.main.async { [weak self] in
      self?.recordDocumentDelegate?.didCompleteRecordDocument(packageResult: AVBeamPackageResult(PackageData()))
    }
  }

  public func startCaptureFace(config: AVBeamCaptureFaceConfig) throws {
    startCaptureFaceConfigCalled = true
    startCaptureFaceConfigCallsCount += 1
    startCaptureFaceConfigReceivedConfig = config
    startCaptureFaceConfigReceivedInvocations.append(config)

    if let error = startCaptureFaceConfigThrowableError {
      throw error
    }
  }

  public func stopCaptureFace() {
    stopCaptureFaceCalled = true
    stopCaptureFaceCallsCount += 1
  }

  public func startNfcScan(config: AVBeamScanNfcConfig) throws {
    startNfcScanConfigCalled = true
    startNfcScanConfigCallsCount += 1
    startNfcScanConfigReceivedConfig = config
    startNfcScanConfigReceivedInvocations.append(config)

    if let error = startNfcScanConfigThrowableError {
      throw error
    }
  }

  public func stopNfcScan() {
    stopNfcScanCalled = true
    stopNfcScanCallsCount += 1
  }

  // MARK: - Test Helper Methods

  /**
   * Resets all call tracking properties to their initial state.
   * Useful for setting up clean state between tests.
   */
  public func reset() {
    // Initialize method
    initializeUsingCalled = false
    initializeUsingCallsCount = 0
    initializeUsingReceivedConfig = nil
    initializeUsingReceivedInvocations.removeAll()
    initializeUsingThrowableError = nil

    // Shutdown method
    shutdownCalled = false
    shutdownCallsCount = 0

    // GL View method
    getGLViewCalled = false
    getGLViewCallsCount = 0
    getGLViewReceivedArguments = nil
    getGLViewReceivedInvocations.removeAll()

    // Camera methods
    startCameraCalled = false
    startCameraCallsCount = 0
    startCameraThrowableError = nil

    stopCameraCalled = false
    stopCameraCallsCount = 0
    stopCameraThrowableError = nil

    // Document scanning methods
    startScanDocumentConfigCalled = false
    startScanDocumentConfigCallsCount = 0
    startScanDocumentConfigReceivedConfig = nil
    startScanDocumentConfigReceivedInvocations.removeAll()
    startScanDocumentConfigThrowableError = nil

    stopScanDocumentCalled = false
    stopScanDocumentCallsCount = 0

    // Document recording methods
    startRecordDocumentConfigCalled = false
    startRecordDocumentConfigCallsCount = 0
    startRecordDocumentConfigReceivedConfig = nil
    startRecordDocumentConfigReceivedInvocations.removeAll()
    startRecordDocumentConfigThrowableError = nil

    stopRecordDocumentCalled = false
    stopRecordDocumentCallsCount = 0

    // Face capture methods
    startCaptureFaceConfigCalled = false
    startCaptureFaceConfigCallsCount = 0
    startCaptureFaceConfigReceivedConfig = nil
    startCaptureFaceConfigReceivedInvocations.removeAll()
    startCaptureFaceConfigThrowableError = nil

    stopCaptureFaceCalled = false
    stopCaptureFaceCallsCount = 0

    // NFC scanning methods
    startNfcScanConfigCalled = false
    startNfcScanConfigCallsCount = 0
    startNfcScanConfigReceivedConfig = nil
    startNfcScanConfigReceivedInvocations.removeAll()
    startNfcScanConfigThrowableError = nil

    stopNfcScanCalled = false
    stopNfcScanCallsCount = 0

    // Reset state
    state = .notInitialized

    // Clear delegates
    messageDelegate = nil
    scanDocumentDelegate = nil
    recordDocumentDelegate = nil
    captureFaceDelegate = nil
    nfcDelegate = nil
  }
}
