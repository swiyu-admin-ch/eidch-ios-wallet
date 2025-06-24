#if DEBUG
import Foundation
@testable import BITTestingCore

// MARK: - Credential + Mockable

extension Credential: Mockable {

  public struct Mock {

    // MARK: Public

    public static let array: [Credential] = [diploma, sampleDisplaysAdditional, sample]
    public static let arrayMultipass: [Credential] = [sample, sample, sample, sample]
    public static let sampleDisplaysAppDefault: Credential = Mocker.decode(fromFile: File.displaysAppDefault, bundle: .module)
    public static let sampleDisplaysFallback: Credential = Mocker.decode(fromFile: File.displaysFallback, bundle: .module)
    public static let sampleDisplaysUnsupported: Credential = Mocker.decode(fromFile: File.displaysUnsupported, bundle: .module)
    public static let sampleDisplaysEmpty: Credential = Mocker.decode(fromFile: File.displaysEmpty, bundle: .module)
    public static let sample: Credential = Mocker.decode(fromFile: Self.File.sample, bundle: .module)
    public static let sampleWithoutKeyBinding: Credential = Mocker.decode(fromFile: Self.File.sampleWithoutKeyBinding, bundle: .module)
    public static let diploma: Credential = Mocker.decode(fromFile: Self.File.diploma, bundle: .module)
    public static let sampleDisplaysAdditional: Credential = Mocker.decode(fromFile: File.displaysAdditional, bundle: .module)
    public static let otherSampleDisplaysAdditional: Credential = Mocker.decode(fromFile: File.displaysAdditional, bundle: .module)
    public static let displaysThemed: Credential = Mocker.decode(fromFile: File.displaysThemed, bundle: .module)

    // MARK: Internal

    struct File {
      static let sample = "credential-database-sample"
      static let sampleWithoutKeyBinding = "credential-database-sample-without-key-binding"
      static let diploma = "credential-database-diploma"
      static let displaysAdditional = "credential-database-locale-additional"
      static let displaysAppDefault = "credential-database-locale-app-default"
      static let displaysFallback = "credential-database-locale-fallback"
      static let displaysUnsupported = "credential-database-locale-unsupported"
      static let displaysThemed = "credential-database-displays-themed"
      static let displaysEmpty = "credential-database-locale-empty"
    }

  }

}
#endif
