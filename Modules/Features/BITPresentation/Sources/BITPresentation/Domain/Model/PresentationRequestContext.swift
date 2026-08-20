import BITCore
import BITCredential
import BITNonCompliance
import BITOpenID
import Foundation
import Spyable

// MARK: - PresentationRequestContext

public class PresentationRequestContext: Equatable {

  // MARK: Lifecycle

  public init(
    requestObjectJWS: RequestObjectJWS,
    compatibleCredentials: [CompatibleCredential],
    transport: PresentationTransport = .network,
    origin: String? = nil)
  {
    self.requestObjectJWS = requestObjectJWS
    self.compatibleCredentials = compatibleCredentials
    self.transport = transport
    self.origin = origin
    if compatibleCredentials.count == 1 {
      selectedCredential = compatibleCredentials.first
    }
  }

  // MARK: Public

  public var trustInformation = TrustInformation(identity: .untrusted, vcSchema: .notProtected)
  public var actorCompliance = ActorCompliance.compliant
  public var legacyVerifierNames: [String: String]?
  public let compatibleCredentials: [CompatibleCredential]
  public var transport: PresentationTransport
  public let origin: String?

  #warning("Remove idTS check once TP 2.0 is enforced")

  public var hasVerifiedQuery: Bool {
    switch transport {
    case .network:
      requestObjectJWS.payload.identityTrustStatement == nil ||
        requestObjectJWS.payload.verificationQueryPublicStatement != nil
    case .proximity:
      true
    }
  }

  public var responseUri: URL? {
    requestObject.responseUri
  }

  // MARK: Internal

  let requestObjectJWS: RequestObjectJWS

  var selectedCredential: CompatibleCredential?

  var requestObject: RequestObject {
    requestObjectJWS.payload
  }

  var verifierDisplays: [VerifierDisplay] {
    let logos = requestObject.clientMetadata?.logoUri?.getAllDisplays() ?? [:]
    let locales = Set(verifierNames.keys)
      .union(logos.keys)
      .sorted()
    return locales.map(createVerifierDisplay)
  }

  func getPreferredVerifierDisplay(considering languageCodes: [UserLanguageCode]) -> VerifierDisplay {
    let logo = requestObject.clientMetadata?.logoUri?.getPreferredDisplay(considering: languageCodes)
    let name = verifierNames.findValue(considering: languageCodes, fallback: "entityName")
    return VerifierDisplay(name: name, logo: logo?.dataURLData, trustInformation: trustInformation, actorCompliance: actorCompliance)
  }

  // MARK: Private

  private var verifierNames: [String: String] {
    guard let identityTrustStatement = requestObject.identityTrustStatement else {
      return legacyVerifierNames ?? requestObject.clientMetadata?.clientName?.getAllDisplays() ?? [:]
    }
    return identityTrustStatement.payload.entityNames.getAllDisplays()
  }

  private func createVerifierDisplay(locale: String) -> VerifierDisplay {
    let name = verifierNames.findValue(considering: [locale], fallback: "entityName")
    let logo = requestObject.clientMetadata?.logoUri?.getPreferredDisplay(considering: [locale])
    return VerifierDisplay(
      name: name,
      locale: locale,
      logo: logo?.dataURLData,
      trustInformation: trustInformation,
      actorCompliance: actorCompliance)
  }
}

// MARK: Hashable

extension PresentationRequestContext: Hashable {
  public static func == (lhs: PresentationRequestContext, rhs: PresentationRequestContext) -> Bool {
    ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
}

#if DEBUG

extension PresentationRequestContext {

  // MARK: Lifecycle

  public convenience init(
    requestObjectJWS: RequestObjectJWS,
    compatibleCredentials: [CompatibleCredential],
    trustInformation: TrustInformation = TrustInformation(identity: .untrusted, vcSchema: .notProtected),
    actorCompliance: ActorCompliance = .compliant,
    transport: PresentationTransport = .network,
    origin: String? = nil)
  {
    self.init(
      requestObjectJWS: requestObjectJWS,
      compatibleCredentials: compatibleCredentials,
      transport: transport,
      origin: origin)
    self.trustInformation = trustInformation
    self.actorCompliance = actorCompliance
  }

  // MARK: Internal

  enum Mock {
    static let vcSdJwtSample = PresentationRequestContext(requestObjectJWS: RequestObjectJWS.Mock.sample, compatibleCredentials: [CompatibleCredential.Mock.BIT], trustInformation: .Mock.trustedIdentity)
    static let vcSdJwtSampleProximity = PresentationRequestContext(requestObjectJWS: RequestObjectJWS.Mock.sampleProximity, compatibleCredentials: [CompatibleCredential.Mock.BIT], trustInformation: TrustInformation(identity: .trustedCheckApp, vcSchema: .trusted), transport: .proximity)
    static let sampleWithoutVerifiedQuery = PresentationRequestContext(requestObjectJWS: RequestObjectJWS.Mock.sampleWithoutVerifiedQuery, compatibleCredentials: CompatibleCredential.Mock.array)
    static let vcSdJwtWithoutVerifiedQuery = PresentationRequestContext(requestObjectJWS: RequestObjectJWS.Mock.identityTrustedWithoutVerifiedQuery, compatibleCredentials: [CompatibleCredential.Mock.BIT], trustInformation: .Mock.trustedIdentity)
    static let vcSdJwtWithoutIdentityTrust = PresentationRequestContext(requestObjectJWS: RequestObjectJWS.Mock.withoutIdentityTrust, compatibleCredentials: [CompatibleCredential.Mock.BIT], trustInformation: .Mock.untrustedIdentity)
    static let vcSdJwtWithUnknownIdentityTrust = PresentationRequestContext(requestObjectJWS: RequestObjectJWS.Mock.sample, compatibleCredentials: [CompatibleCredential.Mock.BIT], trustInformation: .Mock.unknownIdentity)
  }
}
#endif
