import Factory
import FactoryTesting
import Foundation
import Testing
@testable import BITCore

@Suite(.container)
struct URLExtensionsTests {

  // MARK: Internal

  @Test
  func dataURL_validPng_returnsBase64DataAndType() throws {
    let dataUrl = try #require(URL(string: "data:\(Self.pngType);base64,\(Self.dataMock)"))

    #expect(dataUrl.isDataURL)
    #expect(dataUrl.dataURLDataString == Self.dataMock)
    #expect(dataUrl.dataURLData == Data(base64Encoded: Self.dataMock))
    #expect(dataUrl.mediaType == Self.pngType)
  }

  @Test
  func dataURL_noBase64_returnsDataAndType() throws {
    let dataUrl = try #require(URL(string: "data:\(Self.pngType),\(Self.dataMock)"))

    #expect(dataUrl.isDataURL)
    #expect(dataUrl.dataURLDataString == Self.dataMock)
    #expect(dataUrl.dataURLData == Self.dataMock.data(using: .utf8))
    #expect(dataUrl.mediaType == Self.pngType)
  }

  @Test
  func dataURL_noMediaType_returnsBase64DataAndNilType() throws {
    let dataUrl = try #require(URL(string: "data:;base64,\(Self.dataMock)"))

    #expect(dataUrl.isDataURL)
    #expect(dataUrl.dataURLDataString == Self.dataMock)
    #expect(dataUrl.dataURLData == Data(base64Encoded: Self.dataMock))
    #expect(dataUrl.mediaType == nil)
  }

  @Test
  func dataURL_noMediaTypeAndNoBase64_returnsDataAndNilType() throws {
    let dataUrl = try #require(URL(string: "data:,\(Self.dataMock)"))

    #expect(dataUrl.isDataURL)
    #expect(dataUrl.dataURLDataString == Self.dataMock)
    #expect(dataUrl.dataURLData == Self.dataMock.data(using: .utf8))
    #expect(dataUrl.mediaType == nil)
  }

  @Test
  func dataURL_noMediaTypeNoBase64EmptyData_returnsEmptyDataAndNilType() throws {
    let dataUrl = try #require(URL(string: "data:,"))

    #expect(dataUrl.isDataURL)
    #expect(dataUrl.dataURLDataString == "")
    #expect(dataUrl.dataURLData?.isEmpty == true)
    #expect(dataUrl.mediaType == nil)
  }

  @Test
  func dataURL_malformed_returnsNil() throws {
    let dataUrl = try #require(URL(string: "malformed"))

    #expect(!dataUrl.isDataURL)
    #expect(dataUrl.dataURLDataString == nil)
    #expect(dataUrl.dataURLData == nil)
    #expect(dataUrl.mediaType == nil)
  }

  @Test
  func dataURL_emptyString_returnsNil() {
    let dataUrl = URL(string: "")

    #expect(dataUrl == nil)
  }

  @Test(arguments: [
    "dat:\(pngType);base64,\(dataMock)",
    "data\(pngType);base64,\(dataMock)",
    "data:invalid#;base64,\(dataMock)",
    "data:\(pngType);bas64,\(dataMock)",
    "data:\(pngType);base64\(dataMock)",
  ])
  func dataURL_invalidDataURL_returnsNil(stringUrl: String) throws {
    let dataUrl = try #require(URL(string: stringUrl))

    #expect(!dataUrl.isDataURL)
    #expect(dataUrl.dataURLDataString == nil)
    #expect(dataUrl.dataURLData == nil)
    #expect(dataUrl.mediaType == nil)
  }

  @Test(arguments: [
    ("https://test", "https://test"),
    ("https://test.example", "https://test.example"),
    ("https://test.example:1000", "https://test.example:1000"),
    ("https://:1000", "https://:1000"),
    ("https://1.1.1.1", "https://1.1.1.1"),
    ("https://1.1.1.1:1000", "https://1.1.1.1:1000"),
  ])
  func deletingPathAndQuery_withoutPathAndQuery_returnsURL(stringUrl: String, expectedUrl: String) throws {
    let url = try #require(URL(string: stringUrl))

    #expect(url.deletingPathAndQuery?.absoluteString == expectedUrl)
  }

  @Test(arguments: [
    ("https://test.example/", "https://test.example"),
    ("https://test.example/path", "https://test.example"),
    ("https://test.example/path?query=1", "https://test.example"),
    ("https://test.example/path?query=1&other=2", "https://test.example"),
    ("https://test.example:1000/", "https://test.example:1000"),
    ("https://test.example:1000/path", "https://test.example:1000"),
    ("https://test.example:1000/path?query=1", "https://test.example:1000"),
    ("https://test.example:1000/path?query=1&other=2", "https://test.example:1000"),
  ])
  func deletingPathAndQuery_withPathOrQuery_returnsURL(stringUrl: String, expectedUrl: String) throws {
    let url = try #require(URL(string: stringUrl))

    #expect(url.deletingPathAndQuery?.absoluteString == expectedUrl)
  }

  @Test(arguments: [
    "https://example.com",
    "http://example.com",
    "https://www.example.ch/path?query=1",
    "https://issuer.example.foundation/issuer01/oid4vci/api/nonce",
    "https://issuer.example.technology/issuer01/oid4vci/api/nonce",
    "https://issuer.example.someverylongextensionformat/issuer01/oid4vci/api/nonce",
  ])
  func isValidHttpUrl_validUrls_returnsTrue(stringUrl: String) throws {
    let url = try #require(URL(string: stringUrl))

    #expect(url.isValidHttpUrl, "\(stringUrl) should be a valid HTTP URL")
  }

  @Test(arguments: [
    "ftp://example.com",
    "file:///example.com",
    "data:image/png;base64,\(dataMock)",
    "https://",
    "example.com",
  ])
  func isValidHttpUrl_invalidUrls_returnsFalse(stringUrl: String) throws {
    let url = try #require(URL(string: stringUrl))

    #expect(!url.isValidHttpUrl, "\(stringUrl) should not be a valid HTTP URL")
  }

  @Test
  func isValidHttpUrl_maxLengthUrl_returnsTrue() throws {
    let maxHttpUrlLength = Container.shared.maxHttpUrlLength()
    let stringUrl = "https://example.com/" + String(repeating: "a", count: maxHttpUrlLength - 20)
    let url = try #require(URL(string: stringUrl))

    #expect(url.isValidHttpUrl)
  }

  @Test
  func isValidHttpUrl_urlExceedingMaxLength_returnsFalse() throws {
    let maxHttpUrlLength = Container.shared.maxHttpUrlLength()
    let stringUrl = "https://example.com/" + String(repeating: "a", count: maxHttpUrlLength - 19)
    let url = try #require(URL(string: stringUrl))

    #expect(!url.isValidHttpUrl)
  }

  @Test
  func isValidHttpUrl_redosAttackPayload_returnsFalseQuickly() throws {
    let payload = "http://_" + String(repeating: ".hhp0wh", count: 1369)
      + "ttp://_" + String(repeating: ".hhpw", count: 13694)
      + "/_" + String(repeating: ".hhh", count: 13694) + "\u{0}"
    let url = try #require(URL(string: payload))

    let clock = ContinuousClock()
    var isValid = true
    let duration = clock.measure { isValid = url.isValidHttpUrl }

    #expect(!isValid)
    #expect(duration < .seconds(Container.shared.regexEvaluationTimeout()))
  }

  @Test
  func isValidHttpUrl_backtrackingHeavyUrlWithinLengthLimit_returnsFalseQuickly() throws {
    let stringUrl = "https://" + String(repeating: "a.", count: 1019) + "$"
    let url = try #require(URL(string: stringUrl))

    let clock = ContinuousClock()
    var isValid = true
    let duration = clock.measure { isValid = url.isValidHttpUrl }

    #expect(!isValid)
    #expect(duration < .seconds(Container.shared.regexEvaluationTimeout()))
  }

  // MARK: Private

  private static let pngType = "image/png"
  private static let dataMock = "data"
}
