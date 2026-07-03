import BITCore
import BITCredentialShared
import BITEntities
import BITL10n
import Factory
import XCTest
@testable import BITClaimsPathPointer
@testable import BITCredential
@testable import BITOpenID

final class CredentialClaimViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    Container.shared.preferredUserLocales.register { ["en-CH"] }
    Container.shared.userTimeZone.register { .gmt }
  }

  func testImageData_nilClaim_returnsNil() {
    let claim = Self.createClaim(valueType: ValueType.imagePng, value: nil)

    let vm = CredentialClaimViewModel(claim)

    XCTAssertNil(vm.imageData)
  }

  func testNameLabel_withDisplay_returnsDisplayName() {
    let display = CredentialClaimDisplay(locale: "en", name: "forename")
    let claim = Self.createClaim(valueType: ValueType.string, displays: [display])

    let vm = CredentialClaimViewModel(claim)

    XCTAssertEqual(vm.nameLabel, "forename")
  }

  func testNameLabel_withoutDisplay_returnsKey() {
    let claim = Self.createClaim(path: [.string("username")], valueType: ValueType.string, displays: [])

    let vm = CredentialClaimViewModel(claim)

    XCTAssertEqual(vm.nameLabel, "[\"username\"]")
  }

  func testValueLabel_stringValue_returnsValue() {
    let claim = Self.createClaim(valueType: ValueType.string, value: "someText")

    let vm = CredentialClaimViewModel(claim)

    XCTAssertEqual(vm.valueLabel, "someText")
  }

  func testAccessibilityValueLabel_nilValue_returnsEmpty() {
    let claim = Self.createClaim(path: [.string("key")], valueType: ValueType.string, value: nil)

    let vm = CredentialClaimViewModel(claim)

    XCTAssertEqual(vm.accessibilityValueLabel, "[\"key\"], \(L10n.tkGlobalEmpty)")
  }

  func testAccessibilityValueLabel_withValue_returnsKeyAndValue() {
    let display = CredentialClaimDisplay(locale: "en", name: "forename")
    let claim = Self.createClaim(valueType: ValueType.string, value: "John", displays: [display])

    let vm = CredentialClaimViewModel(claim)

    XCTAssertEqual(vm.accessibilityValueLabel, "forename, John")
  }

  func testIsSensitive_boolean_returnsBoolean() {
    for isSensitive in [true, false] {
      let claim = Self.createClaim(valueType: ValueType.numeric, isSensitive: isSensitive)

      let vm = CredentialClaimViewModel(claim)

      XCTAssertEqual(isSensitive, vm.isSensitive, "Error for: \(isSensitive)")
    }
  }

  // MARK: Private

  private static let mockValue = "value"

  private static func createClaim(path: ClaimsPathPointer = [.string("key")], valueType: ValueType = .string, value: String? = mockValue, valueDisplayInfo: String? = nil, isSensitive: Bool = false, displays: [CredentialClaimDisplay] = []) -> CredentialClaim {
    CredentialClaim(path: path, value: value, valueType: valueType.rawValue, valueDisplayInfo: valueDisplayInfo, isSensitive: isSensitive, displays: displays)
  }
}
