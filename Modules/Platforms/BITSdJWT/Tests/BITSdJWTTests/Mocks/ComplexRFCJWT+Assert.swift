// swiftlint: disable force_cast
import Foundation
import XCTest
@testable import BITCore
@testable import BITSdJWT

extension ComplexRFCJWT {

  func assertIn(_ json: JSON) {
    XCTAssertEqual(json.count, 7)
    XCTAssertEqual(json[ComplexRFCJWT.CodingKeys.issuer.rawValue] as? String, issuer)
    XCTAssertEqual(json[ComplexRFCJWT.CodingKeys.issuedAt.rawValue] as? Double, issuedAt?.timeIntervalSince1970)
    XCTAssertEqual(json[ComplexRFCJWT.CodingKeys.expiredAt.rawValue] as? Double, expiredAt?.timeIntervalSince1970)

    let verifiedClaimsJson = json[ComplexRFCJWT.CodingKeys.verifiedClaims.rawValue] as! JSON
    XCTAssertEqual(verifiedClaimsJson.count, 2)

    let verification = verifiedClaimsJson[VerifiedClaims.CodingKeys.verification.rawValue] as! JSON
    XCTAssertEqual(verification.count, 4)
    XCTAssertEqual(verification[VerifiedClaims.Verification.CodingKeys.trustFramework.rawValue] as? String, verifiedClaims?.verification?.trustFramework)
    XCTAssertEqual(verification[VerifiedClaims.Verification.CodingKeys.time.rawValue] as? String, verifiedClaims?.verification?.time)
    XCTAssertEqual(verification[VerifiedClaims.Verification.CodingKeys.verificationProcess.rawValue] as? String, verifiedClaims?.verification?.verificationProcess)

    let evidence = verification[VerifiedClaims.Verification.CodingKeys.evidence.rawValue] as! [JSON]
    XCTAssertEqual(evidence.count, 1)
    XCTAssertEqual(evidence[0].count, 4)
    XCTAssertEqual(evidence[0][VerifiedClaims.Verification.Evidence.CodingKeys.type.rawValue] as? String, verifiedClaims?.verification?.evidence?[0].type)
    XCTAssertEqual(evidence[0][VerifiedClaims.Verification.Evidence.CodingKeys.method.rawValue] as? String, verifiedClaims?.verification?.evidence?[0].method)
    XCTAssertEqual(evidence[0][VerifiedClaims.Verification.Evidence.CodingKeys.time.rawValue] as? String, verifiedClaims?.verification?.evidence?[0].time)

    let document = evidence[0][VerifiedClaims.Verification.Evidence.CodingKeys.document.rawValue] as! JSON
    XCTAssertEqual(document.count, 5)
    XCTAssertEqual(document[VerifiedClaims.Verification.Evidence.Document.CodingKeys.type.rawValue] as? String, verifiedClaims?.verification?.evidence?[0].document?.type)
    XCTAssertEqual(document[VerifiedClaims.Verification.Evidence.Document.CodingKeys.number.rawValue] as? String, verifiedClaims?.verification?.evidence?[0].document?.number)
    XCTAssertEqual(document[VerifiedClaims.Verification.Evidence.Document.CodingKeys.dateOfIssuance.rawValue] as? String, verifiedClaims?.verification?.evidence?[0].document?.dateOfIssuance)
    XCTAssertEqual(document[VerifiedClaims.Verification.Evidence.Document.CodingKeys.dateOfExpiry.rawValue] as? String, verifiedClaims?.verification?.evidence?[0].document?.dateOfExpiry)

    let issuer = document[VerifiedClaims.Verification.Evidence.Document.CodingKeys.issuer.rawValue] as! JSON
    XCTAssertEqual(issuer.count, 2)
    XCTAssertEqual(issuer[VerifiedClaims.Verification.Evidence.Document.Issuer.CodingKeys.name.rawValue] as? String, verifiedClaims?.verification?.evidence?[0].document?.issuer?.name)
    XCTAssertEqual(issuer[VerifiedClaims.Verification.Evidence.Document.Issuer.CodingKeys.country.rawValue] as? String, verifiedClaims?.verification?.evidence?[0].document?.issuer?.country)

    let claims = verifiedClaimsJson[VerifiedClaims.CodingKeys.claims.rawValue] as! JSON
    XCTAssertEqual(claims.count, 6)
    XCTAssertEqual(claims[VerifiedClaims.Claims.CodingKeys.givenName.rawValue] as? String, verifiedClaims?.claims?.givenName)
    XCTAssertEqual(claims[VerifiedClaims.Claims.CodingKeys.familyName.rawValue] as? String, verifiedClaims?.claims?.familyName)
    XCTAssertEqual(claims[VerifiedClaims.Claims.CodingKeys.nationalities.rawValue] as? [String], verifiedClaims?.claims?.nationalities)
    XCTAssertEqual(claims[VerifiedClaims.Claims.CodingKeys.birthdate.rawValue] as? String, verifiedClaims?.claims?.birthdate)

    let placeOfBirth = claims[VerifiedClaims.Claims.CodingKeys.placeOfBirth.rawValue] as! JSON
    XCTAssertEqual(placeOfBirth.count, 2)
    XCTAssertEqual(placeOfBirth[VerifiedClaims.Claims.Address.CodingKeys.locality.rawValue] as? String, verifiedClaims?.claims?.placeOfBirth?.locality)
    XCTAssertEqual(placeOfBirth[VerifiedClaims.Claims.Address.CodingKeys.country.rawValue] as? String, verifiedClaims?.claims?.placeOfBirth?.country)

    let address = claims[VerifiedClaims.Claims.CodingKeys.address.rawValue] as! JSON
    XCTAssertEqual(address.count, 4)
    XCTAssertEqual(address[VerifiedClaims.Claims.Address.CodingKeys.locality.rawValue] as? String, verifiedClaims?.claims?.address?.locality)
    XCTAssertEqual(address[VerifiedClaims.Claims.Address.CodingKeys.country.rawValue] as? String, verifiedClaims?.claims?.address?.country)
    XCTAssertEqual(address[VerifiedClaims.Claims.Address.CodingKeys.postalCode.rawValue] as? String, verifiedClaims?.claims?.address?.postalCode)
    XCTAssertEqual(address[VerifiedClaims.Claims.Address.CodingKeys.street.rawValue] as? String, verifiedClaims?.claims?.address?.street)

    XCTAssertEqual(json[ComplexRFCJWT.CodingKeys.middleName.rawValue] as? String, middleName)
    XCTAssertEqual(json[ComplexRFCJWT.CodingKeys.salutation.rawValue] as? String, salutation)
    XCTAssertEqual(json[ComplexRFCJWT.CodingKeys.msisdn.rawValue] as? String, msisdn)
  }
}
