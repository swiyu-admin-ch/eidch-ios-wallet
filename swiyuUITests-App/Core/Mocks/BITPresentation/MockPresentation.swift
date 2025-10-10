import BITCore
import BITCredential
import BITOpenID
import BITPresentation

// MARK: - CompatibleCredential.Mock

extension CompatibleCredential {
  struct Mock {
    static let array: [CompatibleCredential] = [BIT]
    static let fieldFirstName = PresentationField(jsonPath: "$.firstName", value: CodableValue(value: "Fritz", as: "string"))
    static let fieldLastName = PresentationField(jsonPath: "$.lastName", value: CodableValue(value: "Test", as: "string"))

    static var BIT = CompatibleCredential(credential: .Mock.sampleVC, requestedFields: [fieldFirstName, fieldLastName])
  }
}

// MARK: - PresentationRequestContext.Mock

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
    static let vcSdJwtSample = PresentationRequestContext(requestObject: .Mock.sample, compatibleCredentials: CompatibleCredential.Mock.array)
  }

}
