import BITCore
import BITCredential
import BITOpenID
import Foundation
import Spyable

public typealias InputDescriptorID = String

// MARK: - PresentationRequestContext

public class PresentationRequestContext {

  // MARK: Lifecycle

  public init(presentationRequest: PresentationRequest, compatibleCredentials: [CompatibleCredential]) {
    self.presentationRequest = presentationRequest
    self.compatibleCredentials = compatibleCredentials
    if compatibleCredentials.count == 1 {
      selectedCredential = compatibleCredentials.first
    }
  }

  // MARK: Public

  public var trustInformation = TrustInformation(identity: .untrusted, vcSchema: .notProtected)

  public let compatibleCredentials: [CompatibleCredential]

  public var responseUri: URL {
    requestObject.responseUri
  }

  // MARK: Internal

  let presentationRequest: PresentationRequest

  var selectedCredential: CompatibleCredential?

  var requestObject: RequestObject {
    presentationRequest.requestObject
  }

  var verifierDisplays: [VerifierDisplay] {
    if case .trusted(let trustStatement) = trustInformation.identity {
      getIdentityTrustDisplays(trustStatement)
    } else {
      getClientMetadataDisplays()
    }
  }

  func getPreferredVerifierDisplay(considering languageCodes: [UserLanguageCode]) -> VerifierDisplay {
    let logo = requestObject.clientMetadata?.logoUri?.getPreferredDisplay(considering: languageCodes)
    let name = if case .trusted(let trustStatement) = trustInformation.identity {
      trustStatement.getLocalizedEntityName(considering: languageCodes)
    } else {
      requestObject.clientMetadata?.clientName?.getPreferredDisplay(considering: languageCodes)
    }
    return VerifierDisplay(name: name, logo: logo?.dataURLData, trustInformation: trustInformation)
  }

  // MARK: Private

  private func getIdentityTrustDisplays(_ trustStatement: IdentityTrustStatementJWT) -> [VerifierDisplay] {
    let logos = requestObject.clientMetadata?.logoUri?.getAllDisplays() ?? [:]
    let locales = Set(trustStatement.entityNames.keys)
      .union(logos.keys.filter { !$0.isEmpty })
      .sorted()
    return locales
      .map { locale in
        let name = trustStatement.getLocalizedEntityName(considering: [locale])
        return createVerifierDisplay(locale: locale, name: name)
      }
  }

  private func getClientMetadataDisplays() -> [VerifierDisplay] {
    let names = requestObject.clientMetadata?.clientName?.getAllDisplays() ?? [:]
    return names.keys
      .map { locale in
        createVerifierDisplay(locale: locale, name: names[locale])
      }
  }

  private func createVerifierDisplay(locale: String, name: String?) -> VerifierDisplay {
    let logos = requestObject.clientMetadata?.logoUri?.getAllDisplays() ?? [:]
    return VerifierDisplay(
      name: name,
      locale: locale,
      logo: logos[locale]?.dataURLData ?? logos[""]?.dataURLData,
      trustInformation: trustInformation)
  }
}

#if DEBUG

extension PresentationRequestContext {

  // MARK: Lifecycle

  public convenience init(requestObject: RequestObject, compatibleCredentials: [CompatibleCredential], trustInformation: TrustInformation = TrustInformation(identity: .untrusted, vcSchema: .notProtected)) {
    self.init(presentationRequest: .plain(requestObject), compatibleCredentials: compatibleCredentials, trustInformation: trustInformation)
  }

  public convenience init(presentationRequest: PresentationRequest, compatibleCredentials: [CompatibleCredential], trustInformation: TrustInformation = TrustInformation(identity: .untrusted, vcSchema: .notProtected)) {
    self.init(presentationRequest: presentationRequest, compatibleCredentials: compatibleCredentials)
    self.trustInformation = trustInformation
  }

  // MARK: Internal

  enum Mock {
    static let vcSdJwtSample = PresentationRequestContext(requestObject: .Mock.VcSdJwt.sample, compatibleCredentials: CompatibleCredential.Mock.array)
    static let vcSdJwtWithIdentityTrust = PresentationRequestContext(requestObject: .Mock.VcSdJwt.sample, compatibleCredentials: [CompatibleCredential.Mock.BIT], trustInformation: .Mock.trustedIdentity)
    static let vcSdJwtWithUnknownIdentityTrust = PresentationRequestContext(requestObject: .Mock.VcSdJwt.sample, compatibleCredentials: [CompatibleCredential.Mock.BIT], trustInformation: .Mock.unknownIdentity)
    static let vcSdJwtSampleWithoutInputDescriptors = PresentationRequestContext(requestObject: .Mock.VcSdJwt.sampleWithoutInputDescriptors, compatibleCredentials: CompatibleCredential.Mock.array)
    static let unsupportedResponseTypeVcSdJwtSample = PresentationRequestContext(requestObject: .Mock.VcSdJwt.unsupportedResponseTypeSample, compatibleCredentials: CompatibleCredential.Mock.array)
  }
}
#endif
