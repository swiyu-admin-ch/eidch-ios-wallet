import Spyable

// MARK: - RootCaptureBaseResolverProtocol

@Spyable
public protocol RootCaptureBaseResolverProtocol {
  func resolve(_ captureBases: [any CaptureBase]) throws -> any CaptureBase
}

// MARK: - RootCaptureBaseResolver

public struct RootCaptureBaseResolver: RootCaptureBaseResolverProtocol {

  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public func resolve(_ captureBases: [any CaptureBase]) throws -> any CaptureBase {
    // A root capture base isn't referenced by any other capture base
    let rootCaptureBases = captureBases.filter { base in
      let referencedDigests = captureBases
        .flatMap(\.attributes.values)
        .compactMap(\.referenceDigest)

      return referencedDigests.allSatisfy { $0 != base.digest }
    }

    guard rootCaptureBases.count == 1, let rootCaptureBase = rootCaptureBases.first else {
      throw OcaError.invalidRootCaptureBase
    }
    return rootCaptureBase
  }
}
