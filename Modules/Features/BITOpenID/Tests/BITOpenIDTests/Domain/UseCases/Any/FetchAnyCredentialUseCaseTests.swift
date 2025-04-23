// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import Spyable
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITOca
@testable import BITOpenID

final class FetchAnyCredentialUseCaseFactoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    mockVcSdJwtCredential = AnyCredentialSpy()
    mockVcSdJwtCredential.raw = UUID().uuidString
    spyFetchCredentialVcSdJwtUseCase = FetchAnyCredentialUseCaseProtocolSpy()
    mockDispatcher = [.vcSdJwt: spyFetchCredentialVcSdJwtUseCase]

    Container.shared.anyFetchCredentialDispatcher.register { self.mockDispatcher }

    useCase = FetchAnyCredentialUseCase()
  }

  func testExecuteVcSdJwtUseCase() async throws {
    spyFetchCredentialVcSdJwtUseCase.executeForReturnValue = (mockVcSdJwtCredential, mockRawOcaBundle)

    let anyCredential = try await useCase.execute(for: .Mock.sampleVcSdJwt)

    XCTAssertEqual(mockVcSdJwtCredential.raw, anyCredential.credential.raw)
    XCTAssertEqual(anyCredential.ocaBundle, mockRawOcaBundle)
    XCTAssertTrue(spyFetchCredentialVcSdJwtUseCase.executeForCalled)
  }

  func testExecuteUnsupportedFormat() async throws {
    do {
      _ = try await useCase.execute(for: .Mock.sample)
      XCTFail("An error was expected")
    } catch CredentialFormatError.formatNotSupported {
      /* expected error ✅ */
      XCTAssertFalse(spyFetchCredentialVcSdJwtUseCase.executeForCalled)
    } catch {
      XCTFail("Another error was expected")
    }
  }

  // MARK: Private

  private var useCase: FetchAnyCredentialUseCase!
  private var spyFetchCredentialVcSdJwtUseCase: FetchAnyCredentialUseCaseProtocolSpy!
  private var mockDispatcher: [CredentialFormat: FetchAnyCredentialUseCaseProtocol]!
  private var mockVcSdJwtCredential: AnyCredentialSpy!
  private let mockRawOcaBundle = RawOcaBundle()
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
