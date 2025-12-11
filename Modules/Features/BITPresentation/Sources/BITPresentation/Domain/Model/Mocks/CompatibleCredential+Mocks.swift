#if DEBUG
import BITCore
import BITOpenID

extension CompatibleCredential {
  struct Mock {
    static let array: [CompatibleCredential] = [BIT, diploma]
    static let fieldFirstName = PresentationField(jsonPath: "$.firstName", value: CodableValue(value: "Fritz", as: "string"))
    static let fieldLastName = PresentationField(jsonPath: "$.lastName", value: CodableValue(value: "Test", as: "string"))

    // swiftlint: disable all
    static let BIT = CompatibleCredential(credential: .Mock.sample, requestedFields: [fieldFirstName, fieldLastName])
    static let BITWithoutKeyBinding = CompatibleCredential(credential: .Mock.sampleWithoutKeyBinding, requestedFields: [fieldFirstName, fieldLastName])
    static let diploma = CompatibleCredential(credential: .Mock.diploma, requestedFields: [PresentationField(jsonPath: "$.lastName", value: CodableValue(value: "lastName", as: "string"))])
    // swiftlint: enable all
  }
}
#endif
