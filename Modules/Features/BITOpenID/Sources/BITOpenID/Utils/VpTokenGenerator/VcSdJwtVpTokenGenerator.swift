import BITAnyCredentialFormat
import BITClaimsPathPointer
import BITCrypto
import BITJWT
import BITSdJWT
import BITVault
import Factory
import Foundation

// MARK: - VcSdJwtVpTokenGenerator

struct VcSdJwtVpTokenGenerator: AnyVpTokenGeneratorProtocol {

  // MARK: Internal

  func generate(requestObject: RequestObject, credential: any AnyCredential, keyPair: VaultKeyPair?, paths: [ClaimsPathPointer], withOrigin: String?) throws -> VpToken {
    guard let vcSdJWS = credential as? VcSdJWS else {
      throw AnyVpTokenGeneratorError.invalidFormat
    }
    let sdJwt = vcSdJWS.createSelectiveDisclosure(for: paths)

    guard
      let key = keyPair,
      let jws = try generateKeyBindingJWS(
        from: sdJwt,
        digestAlgorithm: vcSdJWS.digestAlgorithm,
        requestObject: requestObject,
        keyPair: key,
        withOrigin: withOrigin)
    else {
      return sdJwt
    }

    return sdJwt + jws
  }

  // MARK: Private

  @Injected(\.sha256Hasher) private var sha256Hasher: Hashable
  @Injected(\.jwsEncoder) private var jwsEncoder: JWSEncoderProtocol

  private func generateKeyBindingJWS(
    from sdJwt: String,
    digestAlgorithm: SdJwtDigestAlgorithm,
    requestObject: RequestObject,
    keyPair: VaultKeyPair,
    withOrigin: String?) throws
    -> String?
  {
    guard let sdJwtData = sdJwt.data(using: .utf8) else {
      return nil
    }

    let sdHash = hash(data: sdJwtData, with: digestAlgorithm)

    // If the response mode is dcApiJwt and origin is set, use the origin as the audience as specified in
    // https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#appendix-A.4-6
    // else we fail.

    if requestObject.responseMode == .dcApiJWT && withOrigin == nil {
      throw AnyVpTokenGeneratorError.missingDcApiOrigin
    }

    let aud = if let originAud = withOrigin, requestObject.responseMode == .dcApiJWT {
      "origin:\(originAud)"
    } else {
      requestObject.clientIdentifier.raw
    }
    let jwt = KeyBindingJWT(sdHash: sdHash, audience: aud, nonce: requestObject.nonce)
    let data = try jwsEncoder.encode(jwt, using: keyPair)
    return String(data: data, encoding: .utf8)
  }

  private func hash(data: Data, with algorithm: SdJwtDigestAlgorithm) -> String {
    switch algorithm {
    case .sha256:
      sha256Hasher.hash(data).base64URLEncodedString()
    }
  }
}
