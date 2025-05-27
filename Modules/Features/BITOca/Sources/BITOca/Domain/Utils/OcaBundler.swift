import Factory
import Foundation
import Spyable

// MARK: - OcaBundlerProtocol

///
/// Providing functionality for working with OCA (Overlays Capture Base)
/// https://github.com/e-id-admin/open-source-community/blob/main/tech-roadmap/rfcs/oca/spec.md
///
@Spyable
public protocol OcaBundlerProtocol {
  ///
  /// Validates a OCA Bundle JSON and creates the [OcaBundle] data model.
  ///
  /// @param data The JSON string representing an OCA Bundle.
  /// @return The [OcaBundle] data model.
  /// @throws OcaError if validation or creation of OCA Bundle fails.
  func createOcaBundle(_ data: Data) throws -> OcaBundle
}

// MARK: - OcaBundler

struct OcaBundler: OcaBundlerProtocol {

  // MARK: Internal

  func createOcaBundle(_ data: Data) throws -> OcaBundle {
    guard digestsValidator.validate(data) else { throw OcaError.invalidCESRHash }
    let jsonDecoder = JSONDecoder()
    let ocaBundle = try jsonDecoder.decode(OcaBundle.self, from: data)
    try ocaBundleValidator.validate(ocaBundle)
    return ocaBundle
  }

  @Injected(\.ocaCaptureBaseDigestsValidator) private var digestsValidator: OcaCaptureBaseDigestsValidatorProtocol
  @Injected(\.ocaBundleValidator) private var ocaBundleValidator: OcaBundleValidatorProtocol
}
