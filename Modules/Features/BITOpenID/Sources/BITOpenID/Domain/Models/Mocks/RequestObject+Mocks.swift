#if DEBUG
import Foundation
@testable import BITTestingCore

// MARK: - RequestObject.Mock

extension RequestObject {
  public enum Mock {

    // MARK: Public

    public enum VcSdJwt {
      public static let sample: RequestObject = Mocker.decode(fromFile: "request-object-multipass", bundle: Bundle.module)
      public static let sampleData: Data = Mocker.getData(fromFile: "request-object-multipass", bundle: Bundle.module) ?? Data()
      public static let sampleIT: RequestObject = Mocker.decode(fromFile: "request-object-multipass-it", bundle: Bundle.module)
      public static let sampleWithoutInputDescriptors: RequestObject = Mocker.decode(fromFile: "request-object-without-input-descriptors", bundle: Bundle.module)
      public static let sampleMultipassExtraField: RequestObject = Mocker.decode(fromFile: "request-object-multipass-plus-extra-field", bundle: Bundle.module)
      public static let unsupportedResponseTypeSample: RequestObject = Mocker.decode(fromFile: "request-object-unsupported-response-type", bundle: Bundle.module)
      public static let unsupportedResponseModeSample: RequestObject = Mocker.decode(fromFile: "request-object-unsupported-response-mode", bundle: Bundle.module)
      public static let sampleWithClientIdAndWithoutClientIdScheme: RequestObject = Mocker.decode(fromFile: "request-object-with-client-id-without-client-id-scheme", bundle: Bundle.module)
      public static let sampleWithUnsupportedClientIdScheme: RequestObject = Mocker.decode(fromFile: "request-object-with-unsupported-client-id-scheme", bundle: Bundle.module)
      public static let sampleWithUnsupportedClientId: RequestObject = Mocker.decode(fromFile: "request-object-with-unsupported-client-id", bundle: Bundle.module)
      public static let sampleWithoutAnyConstraintsFields: RequestObject = Mocker.decode(fromFile: "request-object-no-constraints-fields", bundle: Bundle.module)
      public static let sampleWithInvalidContraintPath: RequestObject = Mocker.decode(fromFile: "request-object-with-invalid-constraint-path", bundle: Bundle.module)

      public static let jsonSampleData: Data = Mocker.getData(fromFile: "request-object-multipass", bundle: Bundle.module) ?? Data()
      public static let sampleWithoutClientMetadataData: Data = Mocker.getData(fromFile: "request-object-multipass-no-metadata", bundle: Bundle.module) ?? Data()
      public static let sampleWithMissingConstraintsFieldsData: Data = Mocker.getData(fromFile: "request-object-missing-constraints-fields", bundle: Bundle.module) ?? Data()
      public static let sampleWithUnsupportedClientMetadata: Data = Mocker.getData(fromFile: "request-object-multipass-unsupported-metadata", bundle: Bundle.module) ?? Data()
    }

    // MARK: Internal

    enum UnknownFormat {
      static let sampleData: Data = Mocker.getData(fromFile: "request-object-unknown-format", bundle: Bundle.module) ?? Data()
      static let sampleWithoutFormatData: Data = Mocker.getData(fromFile: "request-object-no-format", bundle: Bundle.module) ?? Data()
    }
  }
}
#endif
