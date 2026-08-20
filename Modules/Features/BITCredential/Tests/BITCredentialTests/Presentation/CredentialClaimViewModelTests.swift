import BITCore
import BITCredentialShared
import BITEntities
import BITL10n
import Factory
import Testing
@testable import BITClaimsPathPointer
@testable import BITCredential
@testable import BITOpenID

struct CredentialClaimViewModelTests {

  // MARK: Lifecycle

  init() {
    Container.shared.preferredUserLocales.register { ["en-CH"] }
    Container.shared.userTimeZone.register { .gmt }
  }

  // MARK: Internal

  @Test
  func imageData_nilClaim_returnsNil() {
    let claim = createClaim(valueType: ValueType.imagePng, value: nil)

    let vm = viewModel(claim: claim)

    #expect(vm.imageData == nil)
  }

  @Test
  func nameLabel_withDisplay_returnsDisplayName() {
    let display = CredentialClaimDisplay(locale: "en", name: "forename")
    let claim = createClaim(valueType: ValueType.string, displays: [display])

    let vm = viewModel(claim: claim)

    #expect(vm.nameLabel == "forename")
  }

  @Test
  func nameLabel_withoutDisplay_returnsKey() {
    let claim = createClaim(path: [.string("username")], valueType: ValueType.string, displays: [])

    let vm = viewModel(claim: claim)

    #expect(vm.nameLabel == "[\"username\"]")
  }

  @Test
  func valueLabel_stringValue_returnsValue() {
    let claim = createClaim(valueType: ValueType.string, value: "someText")

    let vm = viewModel(claim: claim)

    #expect(vm.valueLabel == "someText")
  }

  @Test(arguments: [true, false])
  func accessibilityValueLabel_nilValue_returnsEmpty(isSensitive: Bool) {
    let claim = createClaim(path: [.string("key")], valueType: ValueType.string, value: nil, isSensitive: isSensitive)

    let vm = viewModel(claim: claim)

    if isSensitive {
      #expect(vm.accessibilityValueLabel == "[\"key\"], \(L10n.tkGlobalEmpty), \(L10n.tkGlobalSensitiveDataAlt)")
    } else {
      #expect(vm.accessibilityValueLabel == "[\"key\"], \(L10n.tkGlobalEmpty)")
    }
  }

  @Test(arguments: [true, false])
  func accessibilityValueLabel_withValue_returnsKeyAndValue(isSensitive: Bool) {
    let display = CredentialClaimDisplay(locale: "en", name: "forename")
    let claim = createClaim(valueType: ValueType.string, value: "John", isSensitive: isSensitive, displays: [display])

    let vm = viewModel(claim: claim)

    if isSensitive {
      #expect(vm.accessibilityValueLabel == "forename, John, \(L10n.tkGlobalSensitiveDataAlt)")
    } else {
      #expect(vm.accessibilityValueLabel == "forename, John")
    }
  }

  @Test(arguments: [true, false], [true, false])
  func isSensitive(when isClaimSensitve: Bool, and isClusterSensitive: Bool) {
    let claim = createClaim(valueType: ValueType.numeric, isSensitive: isClaimSensitve)

    let vm = viewModel(claim: claim, isSensitive: isClusterSensitive)

    let expectation = isClaimSensitve || isClusterSensitive
    #expect(vm.isSensitive == expectation)
  }

  // MARK: Private

  private func createClaim(
    path: ClaimsPathPointer = [.string("key")],
    valueType: ValueType = .string,
    value: String? = "value",
    valueDisplayInfo: String? = nil,
    isSensitive: Bool = false,
    displays: [CredentialClaimDisplay] = [])
    -> CredentialClaim
  {
    CredentialClaim(
      path: path,
      value: value,
      valueType: valueType.rawValue,
      valueDisplayInfo: valueDisplayInfo,
      isSensitive: isSensitive,
      displays: displays)
  }

  private func viewModel(claim: CredentialClaim, isSensitive: Bool? = nil) -> CredentialClaimViewModel {
    CredentialClaimViewModel(claim, isSensitive: isSensitive ?? claim.isSensitive)
  }
}
