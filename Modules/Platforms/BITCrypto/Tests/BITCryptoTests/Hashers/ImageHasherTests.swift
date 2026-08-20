import Foundation
import Testing
@testable import BITCrypto

// MARK: - ImageHasherTests

struct ImageHasherTests {

  @Test
  func hash_returnsSHA256HexString() {
    let data = Data("image data".utf8)

    let hash = ImageHasher.hash(data)

    #expect(hash == "b41b86dcfdc6219bc2fb987591ad9995bcf3a1e40c2bdd3fdbec622371e6e1af")
  }

  @Test
  func hashFromData_returnsSHA256HexString() {
    let data = Data("image data".utf8)

    let hash = ImageHasher.hash(from: data)

    #expect(hash == "b41b86dcfdc6219bc2fb987591ad9995bcf3a1e40c2bdd3fdbec622371e6e1af")
  }

  @Test
  func hashFromNil_returnsNil() {
    let hash = ImageHasher.hash(from: nil)

    #expect(hash == nil)
  }
}
