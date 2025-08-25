// MARK: - OcaError

public enum OcaError: Error {
  case invalidJsonObject
  case invalidCESRHash
  case invalidRootCaptureBase
  case invalidCaptureBaseReferenceAttribute
  case captureBaseCycleError
  case invalidOverlayCaptureBaseDigest
  case invalidOverlayLanguageCode
  case invalidJsonPath
  case invalidOverlayDataURI
  case invalidClusterOrderingKey
  case invalidEntryOverlay
}
