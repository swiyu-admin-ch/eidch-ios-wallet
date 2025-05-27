// MARK: - OcaError

public enum OcaError: Error {
  case invalidJsonObject
  case invalidCESRHash
  case invalidRootCaptureBase
  case invalidCaptureBaseReferenceAttribute
  case captureBaseCycleError
  case invalidOverlayCaptureBaseDigest
  case invalidOverlayAttributeKey
  case invalidOverlayLanguageCode
}
