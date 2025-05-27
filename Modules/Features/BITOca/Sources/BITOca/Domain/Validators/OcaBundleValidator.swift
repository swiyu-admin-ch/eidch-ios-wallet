import BITCore
import Factory
import Foundation
import Spyable

// MARK: - OcaBundleValidatorProtocol

@Spyable
public protocol OcaBundleValidatorProtocol {
  func validate(_ ocaBundle: OcaBundle) throws
}

// MARK: - OcaBundleValidator

public struct OcaBundleValidator: OcaBundleValidatorProtocol {

  // MARK: Public

  public func validate(_ ocaBundle: OcaBundle) throws {
    try validateCaptureBases(ocaBundle.captureBases)
    try validateOverlays(ocaBundle.overlays, captureBases: ocaBundle.captureBases)
  }

  // MARK: Private

  @Injected(\.localeValidator) private var localeValidator: LocaleValidatorProtocol

  private func validateCaptureBases(_ captureBases: [any CaptureBase]) throws {
    let rootCaptureBase = try findRootCaptureBase(captureBases)
    try validateAttributeReferences(captureBases)
    try validateReferenceCycles(captureBases, captureBase: rootCaptureBase, referencedCaptureBaseDigests: [rootCaptureBase.digest])
  }

  private func findRootCaptureBase(_ captureBases: [any CaptureBase]) throws -> any CaptureBase {
    // A root capture base isn't referenced by any other capture base
    let rootCaptureBases = captureBases.filter { base in
      let attributeTypes = captureBases.flatMap(\.attributes.values)
      return attributeTypes.compactMap(getReferenceAttribute).allSatisfy { $0 != base.digest }
    }
    guard rootCaptureBases.count == 1, let rootCaptureBase = rootCaptureBases.first else {
      throw OcaError.invalidRootCaptureBase
    }
    return rootCaptureBase
  }

  private func validateAttributeReferences(_ captureBases: [any CaptureBase]) throws {
    let allAttributes = captureBases.flatMap(\.attributes.values)
    let referenceAttributes = allAttributes.compactMap(getReferenceAttribute)
    let captureBaseDigests = captureBases.map(\.digest)
    guard referenceAttributes.allSatisfy(captureBaseDigests.contains) else {
      throw OcaError.invalidCaptureBaseReferenceAttribute
    }
  }

  private func validateReferenceCycles(_ captureBases: [any CaptureBase], captureBase: any CaptureBase, referencedCaptureBaseDigests: [String]) throws {
    let nextCaptureBaseDigests = captureBase.attributes.values.compactMap(getReferenceAttribute)
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

  private func getReferenceAttribute(_ type: AttributeType) -> String? {
    switch type {
    case .reference(let digest):
      digest
    case .array(let type):
      getReferenceAttribute(type)
    default:
      nil
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
    }
  }
}
