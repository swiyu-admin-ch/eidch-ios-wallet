import BITCore
import Factory
import Foundation
import Spyable

// MARK: - OcaBundleValidatorProtocol

@Spyable
public protocol OcaBundleValidatorProtocol {
  func validate(_ captureBases: [any CaptureBase], _ overlays: [any Overlay]) throws
}

// MARK: - OcaBundleValidator

public struct OcaBundleValidator: OcaBundleValidatorProtocol {

  // MARK: Public

  public func validate(_ captureBases: [any CaptureBase], _ overlays: [any Overlay]) throws {
    try validateCaptureBases(captureBases)
    try validateOverlays(overlays, captureBases: captureBases)
  }

  // MARK: Private

  @Injected(\.localeValidator) private var localeValidator: LocaleValidatorProtocol
  @Injected(\.rootCaptureBaseResolver) private var rootResolver: RootCaptureBaseResolverProtocol

  private func validateCaptureBases(_ captureBases: [any CaptureBase]) throws {
    let rootCaptureBase = try rootResolver.resolve(captureBases)
    try validateAttributeReferences(captureBases)
    try validateReferenceCycles(captureBases, captureBase: rootCaptureBase, referencedCaptureBaseDigests: [rootCaptureBase.digest])
  }

  private func validateAttributeReferences(_ captureBases: [any CaptureBase]) throws {
    let allAttributes = captureBases.flatMap(\.attributes.values)
    let referenceAttributes = allAttributes.compactMap(\.referenceDigest)
    let captureBaseDigests = captureBases.map(\.digest)
    guard referenceAttributes.allSatisfy(captureBaseDigests.contains) else {
      throw OcaError.invalidCaptureBaseReferenceAttribute
    }
  }

  private func validateReferenceCycles(_ captureBases: [any CaptureBase], captureBase: any CaptureBase, referencedCaptureBaseDigests: [String]) throws {
    let nextCaptureBaseDigests = captureBase.attributes.values.compactMap(\.referenceDigest)
    for nextCaptureBaseDigest in nextCaptureBaseDigests {
      guard !referencedCaptureBaseDigests.contains(nextCaptureBaseDigest) else {
        throw OcaError.captureBaseCycleError
      }
      guard let nextCaptureBase = captureBases.first(where: { $0.digest == nextCaptureBaseDigest }) else {
        throw OcaError.invalidCaptureBaseReferenceAttribute
      }
      try validateReferenceCycles(captureBases, captureBase: nextCaptureBase, referencedCaptureBaseDigests: referencedCaptureBaseDigests + [nextCaptureBaseDigest])
    }
  }

  private func validateOverlays(_ overlays: [any Overlay], captureBases: [any CaptureBase]) throws {
    for overlay in overlays {
      guard captureBases.contains(where: { $0.digest == overlay.captureBaseDigest }) else {
        throw OcaError.invalidOverlayCaptureBaseDigest
      }
      if let localizedOverlay = overlay as? any LocalizedOverlay {
        guard localeValidator.validate(localizedOverlay.language) else {
          throw OcaError.invalidOverlayLanguageCode
        }
      }
      try overlay.validate(with: captureBases, overlays: overlays)
    }
  }
}
