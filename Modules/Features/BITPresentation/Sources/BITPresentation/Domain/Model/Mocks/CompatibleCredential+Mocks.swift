#if DEBUG
import BITClaimsPathPointer
import BITCore
import BITOpenID

extension CompatibleCredential {
  struct Mock {
    static let array: [CompatibleCredential] = [BIT, diploma]
    static let pathFirstName: ClaimsPathPointer = [.string("firstName")]
    static let pathLastName: ClaimsPathPointer = [.string("lastName")]

    // swiftlint: disable all
    static let BIT = CompatibleCredential(credential: .Mock.sample, presentingPaths: [pathFirstName, pathLastName])
    static let BITWithoutKeyBinding = CompatibleCredential(credential: .Mock.sampleWithoutKeyBinding, presentingPaths: [pathFirstName, pathLastName])
    static let diploma = CompatibleCredential(credential: .Mock.diploma, presentingPaths: [pathLastName])
    // swiftlint: enable all
  }
}
#endif
