#if DEBUG
import Foundation
@testable import BITCore

// MARK: - VerifiableCredential + Mockable

extension VerifiableCredential: Mockable {

  public struct Mock {

    // MARK: Public

    public static let array: [VerifiableCredential] = [diploma, sampleDisplaysAdditional, sample]
    public static let arrayMultipass: [VerifiableCredential] = [sample, sample, sample, sample]
    public static let sampleDisplaysAppDefault: VerifiableCredential = Mocker.decode(fromFile: "credential-database-locale-app-default", bundle: .module)
    public static let sampleDisplaysFallback: VerifiableCredential = Mocker.decode(fromFile: "credential-database-locale-fallback", bundle: .module)
    public static let sampleDisplaysUnsupported: VerifiableCredential = Mocker.decode(fromFile: "credential-database-locale-unsupported", bundle: .module)
    public static let sampleDisplaysEmpty: VerifiableCredential = Mocker.decode(fromFile: "credential-database-locale-empty", bundle: .module)
    public static let sample: VerifiableCredential = Mocker.decode(fromFile: "credential-database-sample", bundle: .module)
    public static let sampleWithoutKeyBinding: VerifiableCredential = Mocker.decode(fromFile: "credential-database-sample-without-key-binding", bundle: .module)
    public static let diploma: VerifiableCredential = Mocker.decode(fromFile: "credential-database-diploma", bundle: .module)
    public static let sampleDisplaysAdditional: VerifiableCredential = Mocker.decode(fromFile: File.displaysAdditional, bundle: .module)
    public static let otherSampleDisplaysAdditional: VerifiableCredential = Mocker.decode(fromFile: File.displaysAdditional, bundle: .module)
    public static let displaysThemed: VerifiableCredential = Mocker.decode(fromFile: "credential-database-displays-themed", bundle: .module)
    public static let singleCluster: VerifiableCredential = Mocker.decode(fromFile: "credential-database-single-cluster", bundle: .module)
    public static let multiCluster: VerifiableCredential = Mocker.decode(fromFile: "credential-database-multi-cluster", bundle: .module)
    public static let nestedCluster: VerifiableCredential = Mocker.decode(fromFile: "credential-database-nested-cluster", bundle: .module)
    public static let simpleTypedCluster: VerifiableCredential = Mocker.decode(fromFile: "credential-database-simple-typed-cluster", bundle: .module)

    // MARK: Internal

    struct File {
      static let displaysAdditional = "credential-database-locale-additional"
    }

  }

}
#endif
