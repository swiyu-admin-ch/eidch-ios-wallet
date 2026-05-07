#if DEBUG
import Foundation
@testable import BITCore

// MARK: - VerifiableCredential + Mockable

extension VerifiableCredential: Mockable {

  public struct Mock {

    // MARK: Public

    public static let array: [VerifiableCredential] = [diploma, sampleDisplaysAdditional, sample]
    public static let arrayMultipass: [VerifiableCredential] = [sample, sample, sample, sample]
    public static let sampleDisplaysAppDefault: VerifiableCredential = Mocker.decode(fromFile: File.displaysAppDefault, bundle: .module)
    public static let sampleDisplaysFallback: VerifiableCredential = Mocker.decode(fromFile: File.displaysFallback, bundle: .module)
    public static let sampleDisplaysUnsupported: VerifiableCredential = Mocker.decode(fromFile: File.displaysUnsupported, bundle: .module)
    public static let sampleDisplaysEmpty: VerifiableCredential = Mocker.decode(fromFile: File.displaysEmpty, bundle: .module)
    public static let sample: VerifiableCredential = Mocker.decode(fromFile: Self.File.sample, bundle: .module)
    public static let sampleWithoutKeyBinding: VerifiableCredential = Mocker.decode(fromFile: Self.File.sampleWithoutKeyBinding, bundle: .module)
    public static let diploma: VerifiableCredential = Mocker.decode(fromFile: Self.File.diploma, bundle: .module)
    public static let sampleDisplaysAdditional: VerifiableCredential = Mocker.decode(fromFile: File.displaysAdditional, bundle: .module)
    public static let otherSampleDisplaysAdditional: VerifiableCredential = Mocker.decode(fromFile: File.displaysAdditional, bundle: .module)
    public static let displaysThemed: VerifiableCredential = Mocker.decode(fromFile: File.displaysThemed, bundle: .module)

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
