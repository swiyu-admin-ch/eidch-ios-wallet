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

    inputDescriptorId = getFirstCompatibleCredentialInputDescriptorID(from: requestObject, requests: requests)
  }

  // MARK: Public

  public let requestObject: RequestObject

  public var trustStatement: TrustStatement?
  public var compatibleCredentialsRequestMap: [InputDescriptorID: [CompatibleCredential]] = [:]
  public var selectedCredentials: [InputDescriptorID: CompatibleCredential] = [:]

  // Used for now as first inputDescriptor which has various compatible credentials
  public var inputDescriptorId: InputDescriptorID?

  public var hasCompatibleCredentials: Bool {
    inputDescriptorId != nil
  }

  public func getFirstCompatibleCredentialInputDescriptorID(from requestObject: RequestObject, requests: [InputDescriptorID: [CompatibleCredential]]) -> InputDescriptorID? {
    let filteredRequestIDs = Set(requests.filter { $0.value.count > 1 }.keys)

    if filteredRequestIDs.isEmpty {
      return nil
    }

    return requestObject.presentationDefinition.inputDescriptors
      .map(\.id)
      .first { filteredRequestIDs.contains($0) }
  }
}

#if DEBUG
@testable import BITOpenID

extension PresentationRequestContext {

  // MARK: Lifecycle

  public convenience init(requestObject: RequestObject, compatibleCredentials: [CompatibleCredential], trustStatement: TrustStatement? = nil) {
    self.init(requestObject: requestObject)
    let inputDescriptors = requestObject.presentationDefinition.inputDescriptors.map(\.id)
    var requests: [InputDescriptorID: [CompatibleCredential]] = [:]
    for inputDescriptorID in inputDescriptors {
      requests[inputDescriptorID] = compatibleCredentials
    }
    if let descriptorId = inputDescriptors.first, let credential = compatibleCredentials.first {
      selectedCredentials[descriptorId] = credential
    }

    self.trustStatement = trustStatement
  }

  // MARK: Internal

  enum Mock {
    static let vcSdJwtSample = PresentationRequestContext(requestObject: .Mock.VcSdJwt.sample, compatibleCredentials: CompatibleCredential.Mock.array)
    static let vcSdJwtJwtSample = PresentationRequestContext(requestObject: JWTRequestObject.Mock.sample, compatibleCredentials: CompatibleCredential.Mock.array, trustStatement: TrustStatementPayload.Mock.validSample)
    static let vcSdJwtSampleWithoutInputDescriptors = PresentationRequestContext(requestObject: .Mock.VcSdJwt.sampleWithoutInputDescriptors, compatibleCredentials: CompatibleCredential.Mock.array)
    static let unsupportedResponseTypeVcSdJwtSample = PresentationRequestContext(requestObject: .Mock.VcSdJwt.unsupportedResponseTypeSample, compatibleCredentials: CompatibleCredential.Mock.array)
  }
}
#endif
