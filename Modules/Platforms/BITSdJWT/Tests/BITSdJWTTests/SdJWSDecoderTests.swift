// swiftlint: disable force_unwrapping force_cast
import Factory
import Foundation
import XCTest
@testable import BITJWT
@testable import BITSdJWT
@testable import BITTestingCore

// MARK: - SdJWSDecoderTests

final class SdJWSDecoderTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    success()
    decoder = SdJWSDecoder()
  }

  func testDecode_undisclosed() throws {
    let sdJWT = try SdJWSDecoder().decode(UndisclosedJWT.self, from: UndisclosedJWT.Mock.data)

    XCTAssertEqual(sdJWT.resolvedPayload, UndisclosedJWT.Mock.payload)
    sdJWT.resolvedPayload.assertIn(sdJWT.resolvedJSON)
    XCTAssertEqual(sdJWT.disclosures.count, 0)
    XCTAssertNil(sdJWT.rawKeyBinding)
  }

  func testDecode_typed() throws {
    let sdJWT = try SdJWSDecoder().decode(TypedJWT.self, from: TypedJWT.Mock.data)

    XCTAssertEqual(sdJWT.resolvedPayload, TypedJWT.Mock.payload)
    sdJWT.resolvedPayload.assertIn(sdJWT.resolvedJSON)
    sdJWT.assertDisclosures()
    XCTAssertNil(sdJWT.rawKeyBinding)
  }

  func testDecode_flat() throws {
    let sdJWT = try SdJWSDecoder().decode(FlatJWT.self, from: FlatJWT.Mock.data)

    XCTAssertEqual(sdJWT.resolvedPayload, FlatJWT.Mock.payload)
    XCTAssertEqual(sdJWT.digestAlgorithm, .sha256)
    sdJWT.resolvedPayload.assertIn(sdJWT.resolvedJSON)
    sdJWT.assertDisclosures()
    sdJWT.resolvedPayload.assertIn(sdJWT.resolvedJSON)
  }

  func testDecode_flatWithoutSdAlg_usesSha256() throws {
    let sdJWT = try SdJWSDecoder().decode(FlatJWT.self, from: FlatJWT.Mock.withoutSdAlgData)

    XCTAssertEqual(sdJWT.resolvedPayload, FlatJWT.Mock.payload)
    XCTAssertEqual(sdJWT.digestAlgorithm, .sha256)
    sdJWT.resolvedPayload.assertIn(sdJWT.resolvedJSON)
    sdJWT.assertDisclosures()
    XCTAssertNil(sdJWT.rawKeyBinding)
  }

  func testDecode_flatWithIsoDate() throws {
    var decoder = SdJWSDecoder()
    decoder.dateDecodingStrategy = .iso8601

    let sdJWT = try decoder.decode(IsoJWT.self, from: IsoJWT.Mock.data)

    XCTAssertEqual(sdJWT.resolvedPayload, IsoJWT.Mock.payload)
    sdJWT.resolvedPayload.assertIn(sdJWT.resolvedJSON)
    sdJWT.assertDisclosures()
    XCTAssertNil(sdJWT.rawKeyBinding)
  }

  func testDecode_flatUsingSha384_throws() throws {
    XCTAssertThrowsError(try SdJWSDecoder().decode(FlatJWT.self, from: FlatJWT.Mock.sha384Data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .unsupportedDigestAlgorithm)
    }
  }

  func testDecode_flatUsingSha512_throws() throws {
    XCTAssertThrowsError(try SdJWSDecoder().decode(FlatJWT.self, from: FlatJWT.Mock.sha512Data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .unsupportedDigestAlgorithm)
    }
  }

  func testDecode_flatWithSimpleArrayAndOtherClaims() throws {
    let sdJWT = try SdJWSDecoder().decode(FlatSimpleArrayJWT.self, from: FlatSimpleArrayJWT.Mock.otherClaimsData)

    XCTAssertEqual(sdJWT.resolvedPayload, FlatSimpleArrayJWT.Mock.otherClaimsPayload)
    sdJWT.resolvedPayload.assertIn(sdJWT.resolvedJSON)
    sdJWT.assertDisclosures(hasOtherClaims: true)
    XCTAssertNil(sdJWT.rawKeyBinding)
  }

  func testDecode_flatWithSimpleArrayOnly() throws {
    let sdJWT = try SdJWSDecoder().decode(FlatSimpleArrayJWT.self, from: FlatSimpleArrayJWT.Mock.arrayOnlyData)

    XCTAssertEqual(sdJWT.resolvedPayload, FlatSimpleArrayJWT.Mock.arrayOnlyPayload)
    sdJWT.resolvedPayload.assertIn(sdJWT.resolvedJSON)
    sdJWT.assertDisclosures(hasOtherClaims: false)
    XCTAssertNil(sdJWT.rawKeyBinding)
  }

  func testDecode_flatWithObjectArrayAndOneDisclosedElement() throws {
    let sdJWT = try SdJWSDecoder().decode(FlatObjectArrayJWT.self, from: FlatObjectArrayJWT.Mock.oneDisclosedElementData)

    XCTAssertEqual(sdJWT.resolvedPayload, FlatObjectArrayJWT.Mock.payload)
    sdJWT.resolvedPayload.assertIn(sdJWT.resolvedJSON)
    sdJWT.assertDisclosures(fullyDisclosed: false)
    XCTAssertNil(sdJWT.rawKeyBinding)
  }

  func testDecode_flatWithObjectArrayFullyDisclosed() throws {
    let sdJWT = try SdJWSDecoder().decode(FlatObjectArrayJWT.self, from: FlatObjectArrayJWT.Mock.fullyDisclosedData)

    XCTAssertEqual(sdJWT.resolvedPayload, FlatObjectArrayJWT.Mock.payload)
    sdJWT.resolvedPayload.assertIn(sdJWT.resolvedJSON)
    sdJWT.assertDisclosures(fullyDisclosed: true)
    XCTAssertNil(sdJWT.rawKeyBinding)
  }

  func testDecode_structured() throws {
    let sdJWT = try SdJWSDecoder().decode(StructuredJWT.self, from: StructuredJWT.Mock.data)

    XCTAssertEqual(sdJWT.resolvedPayload, StructuredJWT.Mock.payload)
    sdJWT.resolvedPayload.assertIn(sdJWT.resolvedJSON)
    sdJWT.assertDisclosures()
    XCTAssertNil(sdJWT.rawKeyBinding)
  }

  func testDecode_structuredWithKeyBindingJWT() throws {
    let sdJWT = try SdJWSDecoder().decode(StructuredJWT.self, from: StructuredJWT.Mock.dataWithKeyBinding)

    XCTAssertEqual(sdJWT.resolvedPayload, StructuredJWT.Mock.payload)
    sdJWT.resolvedPayload.assertIn(sdJWT.resolvedJSON)
    XCTAssertEqual(sdJWT.rawKeyBinding, StructuredJWT.Mock.keyBinding)
  }

  func testDecode_recursive() throws {
    let sdJWT = try SdJWSDecoder().decode(RecursiveJWT.self, from: RecursiveJWT.Mock.data)

    XCTAssertEqual(sdJWT.resolvedPayload, RecursiveJWT.Mock.payload)
    sdJWT.resolvedPayload.assertIn(sdJWT.resolvedJSON)
    sdJWT.assertDisclosures()
    XCTAssertNil(sdJWT.rawKeyBinding)
  }

  func testDecode_flatWithDecoys() throws {
    let sdJWT = try SdJWSDecoder().decode(FlatJWT.self, from: FlatJWT.Mock.dataWithDecoys)

    XCTAssertEqual(sdJWT.resolvedPayload, FlatJWT(testKey1: "test_value_1"))
    sdJWT.resolvedPayload.assertIn(sdJWT.resolvedJSON)
    XCTAssertNil(sdJWT.rawKeyBinding)
  }

  func testDecode_flatWithArrayDecoys() throws {
    let sdJWT = try SdJWSDecoder().decode(FlatSimpleArrayJWT.self, from: FlatSimpleArrayJWT.Mock.arrayWithDecoysData)

    XCTAssertEqual(sdJWT.resolvedPayload, FlatSimpleArrayJWT(array: ["test_array_value_1"]))
    sdJWT.resolvedPayload.assertIn(sdJWT.resolvedJSON)
    XCTAssertNil(sdJWT.rawKeyBinding)
  }

  func testDecode_complex() throws {
    let sdJWT = try SdJWSDecoder().decode(ComplexJWT.self, from: ComplexJWT.Mock.data)

    XCTAssertEqual(sdJWT.resolvedPayload, ComplexJWT.Mock.payload)
    sdJWT.resolvedPayload.assertIn(sdJWT.resolvedJSON)
    sdJWT.assertDisclosures()
    XCTAssertNil(sdJWT.rawKeyBinding)
  }

  func testDecode_simpleRFCExample() throws {
    let sdJWT = try SdJWSDecoder().decode(SimpleRFCJWT.self, from: SimpleRFCJWT.Mock.data)

    XCTAssertEqual(sdJWT.resolvedPayload, SimpleRFCJWT.Mock.payload)
    sdJWT.resolvedPayload.assertIn(sdJWT.resolvedJSON)
    XCTAssertNil(sdJWT.rawKeyBinding)
  }

  func testDecode_complexRFCExample() throws {
    let sdJWT = try SdJWSDecoder().decode(ComplexRFCJWT.self, from: ComplexRFCJWT.Mock.data)

    XCTAssertEqual(sdJWT.resolvedPayload, ComplexRFCJWT.Mock.payload)
    sdJWT.resolvedPayload.assertIn(sdJWT.resolvedJSON)
    XCTAssertNil(sdJWT.rawKeyBinding)
  }

  func testDecode_duplicateClaimNameOnDifferentLevels() throws {
    let sdJWT = try SdJWSDecoder().decode(DuplicateNameJWT.self, from: DuplicateNameJWT.Mock.data)

    XCTAssertEqual(sdJWT.resolvedPayload, DuplicateNameJWT.Mock.payload)
    sdJWT.resolvedPayload.assertIn(sdJWT.resolvedJSON)
    XCTAssertNil(sdJWT.rawKeyBinding)
  }

  func testDecode_didResolverHelperReturnsDid_returnsKeyIdentifierDid() throws {
    let sdJWT = try SdJWSDecoder().decode(FlatJWT.self, from: FlatJWT.Mock.data)

    XCTAssertEqual(didResolverHelperSpy.getDidFromCallsCount, 1)
    XCTAssertEqual(sdJWT.keyIdentifierDid, Self.keyIdentifierDidMock)
  }

  func testDecode_didResolverHelperThrows_throws() throws {
    didResolverHelperSpy.getDidFromThrowableError = TestingError.error

    XCTAssertThrowsError(try SdJWSDecoder().decode(FlatJWT.self, from: FlatJWT.Mock.data)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testDecode_emptySdArray() throws {
    // {"_sd":[]}
    let jwt = "eyJ0eXAiOiJmbGF0IiwiYWxnIjoiRVM1MTIifQ.eyJfc2QiOltdfQ.AQIrJ8faKv6VmkoO6ciV-aIXfK5eQ6ofagRVs5Qt3PMHBcnkk7J0s5hdDli8vQkCrs6FMj2YaVAVNZ3oaJ7LK06vAFW8TFKE9rEPWKF9bhAl7SFEvB930aVdqPEW1Ifrk3-OFeFlYa7APhPVGGIYtdlXAQ6AYcyIZkt4-xslrWLfgF5c~"
    let sdJWT = try SdJWSDecoder().decode(FlatJWT.self, from: Data(jwt.utf8))

    XCTAssertTrue(sdJWT.resolvedJSON.isEmpty)
  }

  func testDecode_invalidSdJwt_throwsError() throws {
    let data = "HEADER.PAYLOAD.SIGNATURE".data(using: .utf8)!
    XCTAssertThrowsError(try decoder.decode(FlatJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .invalidRawSdJwt)
    }
  }

  func testDecode_reservedDisclosureName_throwsError() throws {
    let disclosures = [
      "WyJ0ZXN0X3NhbHQiLCAiX3NkIiwgInRlc3RfdmFsdWUiXQ", // ["test_salt", "_sd", "test_value"]
      "WyJ0ZXN0X3NhbHQiLCAiLi4uIiwgInRlc3RfdmFsdWUiXQ", // ["test_salt", "...", "test_value"]
      "WyJ0ZXN0X3NhbHQiLCAiX3NkX2FsZyIsICJ0ZXN0X3ZhbHVlIl0", // ["test_salt", "_sd_alg", "test_value"]
    ]
    for disclosure in disclosures {
      let data = FlatJWT.Mock.JWS.sdJWSData(with: [disclosure])

      XCTAssertThrowsError(try decoder.decode(FlatJWT.self, from: data)) { error in
        XCTAssertEqual(error as? SdJWSDecoderError, .invalidSdClaim(disclosure))
      }
    }
  }

  func testDecode_disclosuresWithDuplicateClaimNames_throwsError() throws {
    let disclosures = [
      "WyJ0ZXN0X3NhbHRfMSIsICJrZXkiLCAidmFsdWUxIl0", // ["test_salt_1", "key", "value1"]
      "WyJ0ZXN0X3NhbHRfMSIsICJrZXkiLCAidmFsdWUyIl0", // ["test_salt_1", "key", "value2"]
    ]

    let jws = "eyJ0eXAiOiJmbGF0IiwiYWxnIjoiRVM1MTIifQ.eyJfc2QiOlsiSzRsbkloTHRwaUFrMS1OTU1PQ2RNQzgySE05NHJna3dqX3pWMEpRcnZKcyIsIlZmYmFQVDBHWlRuekpIS3VDRmJyZnd1a3I2RkNDWDVjeVJxMERFN2RNLUUiXSwiX3NkX2FsZyI6InNoYS0yNTYifQ.AYsm0hEt8zBgK5xyHFTujf6mJQ_GpBEu9ts3V1ScOpSHVRlaQVxtYfBJI_o9kaF7_GA3Y1Y2L4RIe2nvh3SHOh3sAXpZ-sr7MDTE-U39Jvmfpw0yGBVo7Skk68GG4xL57zzk4uxa9JG4jlshk3RmUczw6g_ejpj6EIqBdaM7pVnLNh6U"
    let data = jws.sdJWSData(with: disclosures)

    XCTAssertThrowsError(try decoder.decode(FlatJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .claimAlreadyExists)
    }
  }

  func testDecode_invalidDisclosure_throwsError() throws {
    let disclosures = [
      "InRlc3Rfc2FsdF8xIg", // "test_salt_1"
      "bnVsbA", // null
      "WyJ0ZXN0X3NhbHRfMSJd", // ["test_salt_1"]
      "WyJ0ZXN0X3NhbHRfMSIsICJ0ZXN0X2tleV8xIiwgInRlc3RfdmFsdWVfMSIsICJ0ZXN0Il0", // ["test_salt_1", "test_key_1", "test_value_1", "test"]
      "eyJrZXkiOiAidmFsdWUifQ", // {"key": "value"}
    ]

    for disclosure in disclosures {
      let data = FlatJWT.Mock.JWS.sdJWSData(with: [disclosure])

      XCTAssertThrowsError(try decoder.decode(FlatJWT.self, from: data), "Invalid disclosure didn't throw error: \(disclosure)") { error in
        XCTAssertEqual(error as? SdJWSDecoderError, .invalidDisclosure, "Invalid disclosure threw wrong error: \(disclosure)")
      }
    }
  }

  func testDecode_digestNotFound_throwsError() throws {
    // ["test_salt_4", "test_key_4", "test_value_4"]
    let data = FlatJWT.Mock.JWS.sdJWSData(with: FlatJWT.Mock.disclosures + ["WyJ0ZXN0X3NhbHRfNCIsICJ0ZXN0X2tleV80IiwgInRlc3RfdmFsdWVfNCJd"])

    XCTAssertThrowsError(try decoder.decode(FlatJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .digestNotFound)
    }
  }

  func testDecode_randomString_throwsError() throws {
    let data = "foobar".data(using: .utf8)!
    XCTAssertThrowsError(try decoder.decode(FlatJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .invalidRawSdJwt)
    }
  }

  func testDecode_notString_throwsError() throws {
    let data = Data([0xA0])
    XCTAssertThrowsError(try decoder.decode(FlatJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .invalidRawSdJwt)
    }
  }

  func testDecode_emptyData_throwsError() throws {
    let data = Data()
    XCTAssertThrowsError(try decoder.decode(FlatJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .invalidRawSdJwt)
    }
  }

  func testDecode_sdKeyReferencesJsonObject_throwsError() throws {
    /*
     {
        "test":{
           "_sd":{
              "not_good":"true"
           }
        },
        "_sd_alg":"sha-256"
     }
      */
    let jws = "eyJ0eXAiOiJmbGF0IiwiYWxnIjoiRVM1MTIifQ.eyJ0ZXN0Ijp7Il9zZCI6eyJub3RfZ29vZCI6InRydWUifX0sIl9zZF9hbGciOiJzaGEtMjU2In0.AYiN4WOC_zYKkPxYEZc5Ej7yY_s4GTcAyw2RlhHYZHVZxxYPT5ENiNKrBHfGbXJZnULqr47eYVJDGzZXBNBN3878AclIsqjqsMB5NKLPWSW0KG7lZp6sGAgWCIhVYlNVFmHy-wqOiVRJ_huP9WriXkbfZUT8-0YsHqMC0tBRVJzcaWiw"
    let data = jws.sdJWSData(with: FlatJWT.Mock.disclosures)

    XCTAssertThrowsError(try decoder.decode(FlatJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .invalidDigests)
    }
  }

  func testDecode_sdKeyReferencesJsonPrimitive_throwsError() throws {
    /*
     {
        "test":{
           "_sd":"not good"
        },
        "_sd_alg":"sha-256"
     }
     */
    let jws = "eyJ0eXAiOiJmbGF0IiwiYWxnIjoiRVM1MTIifQ.eyJ0ZXN0Ijp7Il9zZCI6Im5vdCBnb29kIn0sIl9zZF9hbGciOiJzaGEtMjU2In0.AE7u0qbm15sXWrdS56yi0HwUxVGtx49dG59Q3TH6KnPC_5O2dIt145fNQYmOHIMp0zjjkYyNhQ339HC_Jytbug_UAHccAtD58044Ph1ZAdK83u-I4Ls40eRKi_EsF95K43Qt3hSQc7kA1uzIFRLm6Ru0vc0LCv_HSn2i-eF-S8mlN6L2"
    let data = jws.sdJWSData(with: FlatJWT.Mock.disclosures)

    XCTAssertThrowsError(try decoder.decode(FlatJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .invalidDigests)
    }
  }

  func testDecode_sdAlgNotOnRoot_throwsError() throws {
    /*
     {
        "test":{
           "_sd_alg":"sha-256"
        }
     }
     */
    let jws = "eyJ0eXAiOiJmbGF0IiwiYWxnIjoiRVM1MTIifQ.eyJ0ZXN0Ijp7Il9zZF9hbGciOiJzaGEtMjU2In19.APokLlipcA2fv3ozhHQaO_EHy6IMeCEBAfCTcPWSQXhb9hNKWMXTuK6Xop_QhJJ_DD-wIipPb4EifAvCTlN1TnxaAWecNbiHlfwKhh0maasJP6IA0hCKJFOERYXOiHjb8RTG8ndgjruHs8oy68xxvaBsU-PGRAXmO0snXaNkkkYlHlgv"
    let data = jws.sdJWSData(with: FlatJWT.Mock.disclosures)

    XCTAssertThrowsError(try decoder.decode(FlatJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .reservedKeyUsage)
    }
  }

  func testDecode_arrayElementKeyInPayload_throwsError() throws {
    // {"...":"test"}
    let jws = "eyJ0eXAiOiJmbGF0IiwiYWxnIjoiRVM1MTIifQ.eyIuLi4iOiJ0ZXN0In0.AQACF7MRBUBvtw9lqjD3LHMjm17box9HfwOZ767MNLxLpQcS50q7RP_hYb1RkY6De0c6MKuiT57CLloxBlqNoMXNAAphVsYgJCcVFdIdy0KweNfbW3kT3o3uCSrfRhTkk9YkQQy4akQPJ1qgdICZsnj6HQGz_JBK3cLAIzckYFpP6Yw3"
    let data = jws.sdJWSData(with: FlatJWT.Mock.disclosures)

    XCTAssertThrowsError(try decoder.decode(FlatJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .reservedKeyUsage)
    }
  }

  func testDecode_duplicateDigestInSameArray_throwsError() throws {
    /*
      {
        "_sd":[
           "YRLf606clwt4-hjyGze49ySFi6VCmwb9n5hwb4VUJSY",
           "YRLf606clwt4-hjyGze49ySFi6VCmwb9n5hwb4VUJSY"
        ],
        "_sd_alg":"sha-256"
     }
      */
    let jws = "eyJ0eXAiOiJmbGF0IiwiYWxnIjoiRVM1MTIifQ.eyJfc2QiOlsiWVJMZjYwNmNsd3Q0LWhqeUd6ZTQ5eVNGaTZWQ213YjluNWh3YjRWVUpTWSIsIllSTGY2MDZjbHd0NC1oanlHemU0OXlTRmk2VkNtd2I5bjVod2I0VlVKU1kiXSwiX3NkX2FsZyI6InNoYS0yNTYifQ.AOhYb6lnqer2VomCqPu1s15kQTWbbioPuNEqf_7j8aF4tAhlVZ1dGgUBVZIkB5oE5gmF9ixvLBqBVoJBn2rO79NJAPP8owvNhB0R7XxkEynosrLcYE9CqxG9pCVLD5brwn7Tzk6UQ5QuFkTheRVa2Q75WSBFPWzcZlFSESGdHG9RV0hM"
    let data = jws.sdJWSData(with: FlatJWT.Mock.disclosures)

    XCTAssertThrowsError(try decoder.decode(FlatJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .duplicatedDigest)
    }
  }

  func testDecode_duplicateDigestInDifferentArrays_throwsError() throws {
    /*
     {
        "_sd":[
           "YRLf606clwt4-hjyGze49ySFi6VCmwb9n5hwb4VUJSY"
        ],
        "array":[
           {
              "...":"YRLf606clwt4-hjyGze49ySFi6VCmwb9n5hwb4VUJSY"
           }
        ],
        "_sd_alg":"sha-256"
     }
      */
    let jws = "eyJ0eXAiOiJmbGF0IiwiYWxnIjoiRVM1MTIifQ.eyJfc2QiOlsiWVJMZjYwNmNsd3Q0LWhqeUd6ZTQ5eVNGaTZWQ213YjluNWh3YjRWVUpTWSJdLCJhcnJheSI6W3siLi4uIjoiWVJMZjYwNmNsd3Q0LWhqeUd6ZTQ5eVNGaTZWQ213YjluNWh3YjRWVUpTWSJ9XSwiX3NkX2FsZyI6InNoYS0yNTYifQ.AetmUJniNzDBHh4Kn_UwP8ovsCdcjAYha2DoIEelSHhsWpoc9Y6ZTntWFQHCD_5gpVUMHu_tgOWMfM_BD31f6viqAdGULrwFmd2hTJJixXPZo6BOQohb4wKxay0OysklTr1ffoLWQoKiKFuucP7uTrP0UaSILCXzsQV3SBS3y2t_dc0M"
    let data = jws.sdJWSData(with: FlatJWT.Mock.disclosures)

    XCTAssertThrowsError(try decoder.decode(FlatJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .duplicatedDigest)
    }
  }

  func testDecode_unsupportedDigestAlgorithm_throwsError() throws {
    /*
     {
       "_sd_alg": "invalid"
     }
     */
    let jws = "eyJ0eXAiOiJmbGF0IiwiYWxnIjoiRVM1MTIifQ.eyJfc2RfYWxnIjoiaW52YWxpZCJ9.ALWvWonZuEebBdEXMpSVce8QMuuyBkUTCe4wU-MLae0tgpmwzUYYSRkZ6TDzvziEROmHwN3wSJVp31C0kSabZo_iAaVmsSa08C90XhR2xc9jDCw4qY2zMtR_7PyN1gP17ZzOOJMdiZrqGmLb7TTGIYFRffwQxnlYbPpLpKgUTQ8BY6p9"
    let data = jws.sdJWSData(with: FlatJWT.Mock.disclosures)

    XCTAssertThrowsError(try decoder.decode(FlatJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .unsupportedDigestAlgorithm)
    }
  }

  func testDecode_nonStringDigestAlgorithm_throwsError() throws {
    /*
     {
       "_sd_alg": 123
     }
     */
    let jws = "eyJ0eXAiOiJmbGF0IiwiYWxnIjoiRVM1MTIifQ.eyJfc2RfYWxnIjoxMjN9.ATYtdZatwQvoqUU6YGt5EEONjoxWQlmcBIjfnGIQjVWfAG8Z5PIXQTpqB6az5P4Bt8wXt9jwDc5QSp_cgMfReo7KAEzfPesGiKr6D9XZxim0jfV07_RWVfeNAi8Vbz5C678OMl_op1IDYArwgrbYM8MuCzpR7H-YtQ5paXypEm3rvynf"
    let data = jws.sdJWSData(with: FlatJWT.Mock.disclosures)

    XCTAssertThrowsError(try decoder.decode(FlatJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .unsupportedDigestAlgorithm)
    }
  }

  func testDecode_nonDisclosableClaimInDisclosure_throwsError() throws {
    // ["test_salt", "iss", "value"]
    let disclosure = "WyJ0ZXN0X3NhbHQiLCAiaXNzIiwgInZhbHVlIl0"
    // {}
    let jws = "eyJ0eXAiOiJmbGF0IiwiYWxnIjoiRVM1MTIifQ.e30.AfTpiH-4UImlQZmM9AxEZJ45axWIAlz_BRWetjX6jRWCjzWXMIimSB7ltfTy2GXIWW0SNbP_IDF6FZgpb7Oybnk6AB362Bc2tUNKEy1N4hhMjxIIi3I1Vug4zCgxtmi3ffpBHMitfDJK6Oz8muWjoK4vHMXQZujwkv0NqkJZtUhLu3NM"
    let data = jws.sdJWSData(with: [disclosure])
    decoder = SdJWSDecoder(nonSelectivelyDisclosableClaims: ["iss"])

    XCTAssertThrowsError(try decoder.decode(FlatJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .invalidSdClaim(disclosure))
    }
  }

  @MainActor
  func testDecode_decoder_throwsError() throws {
    let data = FlatJWT.Mock.data
    var decoderMock = JWSDecoderMock<FlatJWT>()
    decoderMock.throwingError = TestingError.error
    Container.shared.jwsDecoder.register { @MainActor in decoderMock }

    XCTAssertThrowsError(try SdJWSDecoder().decode(FlatJWT.self, from: data)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private static let keyIdentifierDidMock = "did:tdw:example"

  private var decoder = SdJWSDecoder()

  private var didResolverHelperSpy = DidResolverHelperProtocolSpy()

  private func registerMocks() {
    didResolverHelperSpy = DidResolverHelperProtocolSpy()
    Container.shared.didResolverHelper.register { self.didResolverHelperSpy }
  }

  private func success() {
    didResolverHelperSpy.getDidFromReturnValue = Self.keyIdentifierDidMock
  }
}
