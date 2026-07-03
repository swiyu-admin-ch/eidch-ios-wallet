#if DEBUG
import Foundation
@testable import BITCore

extension OcaBundle: Mockable {
  enum Mock {
    static let elfa = create(from: "oca-bundle-elfa")
    static let dataSource1x0SimpleSample = create(from: "oca-bundle-one-attribute-data-source-1x0")
    static let simpleSample = create(from: "oca-bundle-simple-sample")
    static let specialDataTypes = create(from: "oca-bundle-special-data-types")
    static let nested = create(from: "oca-bundle-nested")
    static let chasseral = create(from: "oca-bundle-chasseral")
    static let simpleNested = create(from: "oca-bundle-simple-nested")
    static let ocaClusters = create(from: "oca-bundle-oca-clusters")
    static let oneCaptureBase = create(from: "oca-bundle-one-capture-base")
    static let arrayObjectNestedClaim = create(from: "oca-bundle-array-object-nested-claim")
    static let standardOverlay = create(from: "oca-bundle-standard-overlay")
    static let emptyLabelOverlay = create(from: "oca-empty-label-overlay")

    static let elfaData: Data = getData(fromFile: "oca-bundle-elfa", bundle: Bundle.module) ?? Data()
    static let nestedData: Data = getData(fromFile: "oca-bundle-nested", bundle: Bundle.module) ?? Data()
    static let chasseralData: Data = getData(fromFile: "oca-bundle-chasseral", bundle: Bundle.module) ?? Data()
    static let simpleSampleData: Data = getData(fromFile: "oca-bundle-simple-sample", bundle: Bundle.module) ?? Data()
    static let missingCaptureBasesData: Data = getData(fromFile: "oca-bundle-missing-capture-bases", bundle: Bundle.module) ?? Data()
    static let malformedCaptureBasesData: Data = getData(fromFile: "oca-bundle-malformed-capture-bases", bundle: Bundle.module) ?? Data()
    static let missingOverlaysData: Data = getData(fromFile: "oca-bundle-missing-overlays", bundle: Bundle.module) ?? Data()
    static let malformedOverlaysData: Data = getData(fromFile: "oca-bundle-malformed-overlay", bundle: Bundle.module) ?? Data()
    static let emptyBrandingOverlayData: Data = getData(fromFile: "oca-empty-branding-overlay", bundle: Bundle.module) ?? Data()

    // swiftlint:disable force_try
    static func create(from file: String) -> OcaBundle {
      let data = getData(fromFile: file, bundle: Bundle.module) ?? Data()
      return try! OcaBundler().createOcaBundle(data)
    }
    // swiftlint:enable force_try
  }
}

#endif
