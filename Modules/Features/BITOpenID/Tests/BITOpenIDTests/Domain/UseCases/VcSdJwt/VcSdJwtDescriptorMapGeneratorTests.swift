import XCTest
@testable import BITOpenID

final class VcSdJwtDescriptorMapGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    generator = VcSdJwtDescriptorMapGenerator()
  }

  func testExecute_happyPath() throws {
    guard let inputDescriptor = RequestObject.Mock.VcSdJwt.sample.presentationDefinition?.inputDescriptors.first else {
      XCTFail("Missing input descriptor fixture")
      return
    }
    let mockFormat = "mock-format"

    let descriptorMap = try generator.generate(using: inputDescriptor, vcFormat: mockFormat)

    XCTAssertFalse(descriptorMap.isEmpty)
    XCTAssertEqual(descriptorMap.count, 1)
    XCTAssertEqual(mockFormat, descriptorMap.first?.format)
  }

  // MARK: Private

  // swiftlint:disable all
  private var generator: VcSdJwtDescriptorMapGenerator!
  // swiftlint:enable all
}
