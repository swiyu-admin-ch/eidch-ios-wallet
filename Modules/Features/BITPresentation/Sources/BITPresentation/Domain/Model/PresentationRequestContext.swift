import BITCore
import BITCredential
import BITOpenID
import Foundation
import Spyable

public typealias InputDescriptorID = String

// MARK: - PresentationRequestContext

public class PresentationRequestContext {

  // MARK: Lifecycle

  public init(requestObject: RequestObject) {
    self.requestObject = requestObject
  }

  public init(requestObject: RequestObject, requests: [InputDescriptorID: [CompatibleCredential]]) {
    self.requestObject = requestObject
    compatibleCredentialsRequestMap = requests

    if let id = requestObject.firstInputDescriptor?.id, let credentials = requests[id] {
      if credentials.count > 1 {
        inputDescriptorId = id // this triggers the credential selection for now
      } else if credentials.count == 1, let credential = credentials.first {
        selectedCredentials[id] = credential
      }
    }
  }

  // MARK: Public

  public let requestObject: RequestObject

  public var trustInformation = TrustInformation(identity: .untrusted, vcSchema: .notProtected)
  public var compatibleCredentialsRequestMap = [InputDescriptorID: [CompatibleCredential]]()
  public var selectedCredentials = [InputDescriptorID: CompatibleCredential]()

  public var inputDescriptorId: InputDescriptorID?

  public var hasCompatibleCredentials: Bool {
    if inputDescriptorId != nil {
      return true
    }
    guard let inputDescriptorId = requestObject.firstInputDescriptor?.id else { return false }
    return selectedCredentials[inputDescriptorId] != nil
  }

  // MARK: Internal

  func getVerifierDisplay(considering languageCodes: [UserLanguageCode]) -> VerifierDisplay {
    let logo = requestObject.clientMetadata?.logoUri?.getPreferredDisplay(considering: languageCodes)
    let name = if case .trusted(let trustStatement) = trustInformation.identity {
      trustStatement.getLocalizedEntityName(considering: languageCodes)
    } else {
      requestObject.clientMetadata?.clientName?.getPreferredDisplay(considering: languageCodes)
    }
    return VerifierDisplay(name: name, logo: logo?.dataURLData, trustInformation: trustInformation)
  }
}

#if DEBUG
@testable import BITOpenID

extension PresentationRequestContext {

  // MARK: Lifecycle

  public convenience init(requestObject: RequestObject, compatibleCredentials: [CompatibleCredential], trustInformation: TrustInformation = TrustInformation(identity: .untrusted, vcSchema: .notProtected)) {
    self.init(requestObject: requestObject)
    let inputDescriptors = requestObject.presentationDefinition.inputDescriptors.map(\.id)
    var requests = [InputDescriptorID: [CompatibleCredential]]()
    for inputDescriptorID in inputDescriptors {
      requests[inputDescriptorID] = compatibleCredentials
    }
    if let descriptorId = inputDescriptors.first, let credential = compatibleCredentials.first {
      selectedCredentials[descriptorId] = credential
    }

    self.trustInformation = trustInformation
  }

  // MARK: Internal

  enum Mock {
    static let vcSdJwtSample = PresentationRequestContext(requestObject: .Mock.VcSdJwt.sample, compatibleCredentials: CompatibleCredential.Mock.array)
    static let vcSdJwtWithIdentityTrust = PresentationRequestContext(requestObject: .Mock.VcSdJwt.sample, compatibleCredentials: CompatibleCredential.Mock.array, trustInformation: .Mock.trustedIdentity)
    static let vcSdJwtSampleWithoutInputDescriptors = PresentationRequestContext(requestObject: .Mock.VcSdJwt.sampleWithoutInputDescriptors, compatibleCredentials: CompatibleCredential.Mock.array)
    static let unsupportedResponseTypeVcSdJwtSample = PresentationRequestContext(requestObject: .Mock.VcSdJwt.unsupportedResponseTypeSample, compatibleCredentials: CompatibleCredential.Mock.array)
  }
}
#endif
