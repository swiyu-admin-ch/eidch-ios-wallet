#if DEBUG
import BITCore
import BITOpenID

extension CompatibleCredential {
  struct Mock {
    static let array: [CompatibleCredential] = [BIT, diploma]
    static let fieldFirstName = PresentationField(jsonPath: "$.firstName", value: CodableValue(value: "Fritz", as: "string"))
    static let fieldLastName = PresentationField(jsonPath: "$.lastName", value: CodableValue(value: "Test", as: "string"))

    // swiftlint: disable all
    static var BIT: CompatibleCredential { .init(credential: .Mock.sample, requestedFields: [fieldFirstName, fieldLastName]) }
    static var BITWithoutKeyBinding: CompatibleCredential { .init(credential: .Mock.sampleWithoutKeyBinding, requestedFields: [fieldFirstName, fieldLastName]) }
    static var diploma: CompatibleCredential { .init(credential: .Mock.diploma, requestedFields: [PresentationField(jsonPath: "$.lastName", value: CodableValue(value: "lastName", as: "string"))]) }
    // swiftlint: enable all
  }
}
#endif
