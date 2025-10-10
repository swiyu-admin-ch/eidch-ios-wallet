import Factory
import Spyable
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITAnyCredentialFormatMocks
@testable import BITCore
@testable import BITOpenID
@testable import BITTestingCore

final class PresentationFieldsValidatorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    anyCredentialJsonGeneratorSpy = AnyCredentialJsonGeneratorProtocolSpy()

    Container.shared.anyCredentialJsonGenerator.register { self.anyCredentialJsonGeneratorSpy }

    validator = PresentationFieldsValidator()
  }

  func testValidate_MultipleFieldsOnePath_ReturnsFields() throws {
    let anyCredential: AnyCredential = MockAnyCredential()
    let mockFields = [Field(path: [Self.mockPath1]), Field(path: [Self.mockPath2])]

    anyCredentialJsonGeneratorSpy.generateForReturnValue = Self.mockJson

    let fields = try validator.validate(anyCredential, with: mockFields)

    XCTAssertEqual(fields.count, 2)
    XCTAssertEqual(fields[0].jsonPath, Self.mockPath1)
    XCTAssertEqual(fields[0].value.rawValue, Self.mockValue1)
    XCTAssertEqual(fields[1].jsonPath, Self.mockPath2)
    XCTAssertEqual(fields[1].value.rawValue, Self.mockValue2)
  }

  func testValidate_MultipleFieldsMultiplePaths_ReturnsFields() throws {
    let anyCredential: AnyCredential = MockAnyCredential()
    let mockFields = [Field(path: [Self.mockPath1, Self.mockPath2]), Field(path: [Self.mockOtherPath, Self.mockPath4])]

    anyCredentialJsonGeneratorSpy.generateForReturnValue = Self.mockJson

    let fields = try validator.validate(anyCredential, with: mockFields)

    XCTAssertEqual(fields.count, 2)
    XCTAssertEqual(fields[0].jsonPath, Self.mockPath1)
    XCTAssertEqual(fields[0].value.rawValue, Self.mockValue1)
    XCTAssertEqual(fields[1].jsonPath, Self.mockPath4)
    XCTAssertEqual(fields[1].value.rawValue, Self.mockValue4)
  }

  func testValidate_NoRequiredField_ReturnsEmptyList() throws {
    let anyCredential: AnyCredential = MockAnyCredential()
    let mockFields = [Field]()

    anyCredentialJsonGeneratorSpy.generateForReturnValue = Self.mockJson

    let fields = try validator.validate(anyCredential, with: mockFields)

    XCTAssertTrue(fields.isEmpty)
  }

  func testValidate_NoRequiredPath_ReturnsEmptyList() throws {
    let anyCredential: AnyCredential = MockAnyCredential()
    let mockFields = [Field(path: [])]

    anyCredentialJsonGeneratorSpy.generateForReturnValue = Self.mockJson

    let fields = try validator.validate(anyCredential, with: mockFields)

    XCTAssertTrue(fields.isEmpty)
  }

  func testValidate_NoMatchingPath_ThrowsError() throws {
    let anyCredential: AnyCredential = MockAnyCredential()
    let mockFields = [Field(path: [Self.mockPath1, Self.mockPath2]), Field(path: [Self.mockPath3, Self.mockPath4])]

    anyCredentialJsonGeneratorSpy.generateForReturnValue = "{\"otherPath\": \"otherValue\"}"

    XCTAssertThrowsError(try validator.validate(anyCredential, with: mockFields)) { error in
      XCTAssertEqual(error as? PresentationFieldsValidatorError, .missingRequiredField)
    }
  }

  func testValidate_NoMatchingField_ThrowsError() throws {
    let anyCredential: AnyCredential = MockAnyCredential()
    // we only enforce filters for the vct path
    let mockFields = [Field(path: [Self.vctPath], filter: Filter(const: Self.mockValue1, type: Self.stringType))]

    anyCredentialJsonGeneratorSpy.generateForReturnValue = Self.mockJson

    XCTAssertThrowsError(try validator.validate(anyCredential, with: mockFields)) { error in
      XCTAssertEqual(error as? PresentationFieldsValidatorError, .missingRequiredField)
    }
  }

  func testValidate_AnyCredentialJsonGeneratorThrows_ReturnsEmptyList() throws {
    let anyCredential: AnyCredential = MockAnyCredential()
    let mockFields = [Field]()

    anyCredentialJsonGeneratorSpy.generateForThrowableError = TestingError.error

    let fields = try validator.validate(anyCredential, with: mockFields)

    XCTAssertTrue(fields.isEmpty)
  }

  func testValidate_JsonWithArrays_ReturnsOnlyFirst() throws {
    let anyCredential: AnyCredential = MockAnyCredential()
    let arrayPath = "$[0]"
    let mockFields = [Field(path: [arrayPath])]

    anyCredentialJsonGeneratorSpy.generateForReturnValue = #"["\#(Self.mockValue1)", "\#(Self.mockValue2)"]"#

    let fields = try validator.validate(anyCredential, with: mockFields)

    XCTAssertEqual(fields.count, 1)
    XCTAssertEqual(fields[0].jsonPath, arrayPath)
    XCTAssertEqual(fields[0].value.rawValue, Self.mockValue1)
  }

  // MARK: Private

  private static let mockJson = String.Mock.jsonPathsSample
  private static let mockPath1 = "$.path1"
  private static let mockValue1 = "value1"
  private static let mockPath2 = "$.path2"
  private static let mockValue2 = "value2"
  private static let mockPath3 = "$.path3"
  private static let mockPath4 = "$.path4"
  private static let mockValue4 = "value4"
  private static let mockOtherPath = "$.otherPath"

  private static let vctPath = "$.vct"
  private static let vctType = "vctType"
  private static let stringType = "string"

  // swiftlint:disable all
  private var validator: PresentationFieldsValidator!
  private var anyCredentialJsonGeneratorSpy: AnyCredentialJsonGeneratorProtocolSpy!
  // swiftlint:enable all
}
