import BITCore
import BITCredential
import BITOpenID
import Foundation
import Spyable

// MARK: - PresentationRequestContext

public class PresentationRequestContext: Equatable {

  // MARK: Lifecycle

  public init(
    requestObjectJWS: RequestObjectJWS,
    compatibleCredentials: [CompatibleCredential],
    transport: PresentationTransport = .network)
  {
    self.requestObjectJWS = requestObjectJWS
    self.compatibleCredentials = compatibleCredentials
    self.transport = transport
    if compatibleCredentials.count == 1 {
      selectedCredential = compatibleCredentials.first
    }
  }

  // MARK: Public

  public var trustInformation = TrustInformation(identity: .untrusted, vcSchema: .notProtected)

  public let compatibleCredentials: [CompatibleCredential]
  public var transport: PresentationTransport

  public var responseUri: URL? {
    requestObject.responseUri
  }

  public static func == (lhs: PresentationRequestContext, rhs: PresentationRequestContext) -> Bool {
    lhs.requestObject == rhs.requestObject &&
      lhs.compatibleCredentials == rhs.compatibleCredentials &&
      lhs.transport == rhs.transport &&
      lhs.selectedCredential == rhs.selectedCredential &&
      lhs.responseUri == rhs.responseUri
  }

  // MARK: Internal

  let requestObjectJWS: RequestObjectJWS

  var selectedCredential: CompatibleCredential?

  var requestObject: RequestObject {
    requestObjectJWS.payload
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

// MARK: Hashable

extension PresentationRequestContext: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(trustInformation)
  }
}

#if DEBUG

extension PresentationRequestContext {

  // MARK: Lifecycle

  public convenience init(
    requestObjectJWS: RequestObjectJWS,
    compatibleCredentials: [CompatibleCredential],
    trustInformation: TrustInformation = TrustInformation(identity: .untrusted, vcSchema: .notProtected),
    transport: PresentationTransport = .network)
  {
    self.init(
      requestObjectJWS: requestObjectJWS,
      compatibleCredentials: compatibleCredentials,
      transport: transport)
    self.trustInformation = trustInformation
  }

  // MARK: Internal

  enum Mock {
    static let vcSdJwtSample = PresentationRequestContext(requestObjectJWS: RequestObjectJWS.Mock.sample, compatibleCredentials: CompatibleCredential.Mock.array)
    static let vcSdJwtWithIdentityTrust = PresentationRequestContext(requestObjectJWS: RequestObjectJWS.Mock.identityTrust, compatibleCredentials: [CompatibleCredential.Mock.BIT], trustInformation: .Mock.trustedIdentity)
    static let vcSdJwtWithUnknownIdentityTrust = PresentationRequestContext(requestObjectJWS: RequestObjectJWS.Mock.sample, compatibleCredentials: [CompatibleCredential.Mock.BIT], trustInformation: .Mock.unknownIdentity)
  }
}
#endif
