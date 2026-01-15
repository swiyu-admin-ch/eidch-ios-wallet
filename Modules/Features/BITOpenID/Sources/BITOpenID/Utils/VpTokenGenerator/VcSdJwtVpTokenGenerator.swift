import BITAnyCredentialFormat
import BITCrypto
import BITJWT
import BITSdJWT
import BITVault
import Factory

// MARK: - VcSdJwtVpTokenGenerator

struct VcSdJwtVpTokenGenerator: AnyVpTokenGeneratorProtocol {

  // MARK: Internal

  func generate(requestObject: RequestObject, credential: any AnyCredential, keyPair: VaultKeyPair?, fields: [String]) throws -> VpToken {
    guard let vcSdJWS = credential as? VcSdJWS else {
      throw AnyVpTokenGeneratorError.invalidFormat
    }
    let sdJwt = vcSdJWS.createSelectiveDisclosure(for: fields)

    guard
      let key = keyPair,
      let jws = try generateKeyBindingJWS(from: sdJwt, requestObject: requestObject, keyPair: key)
    else {
      return sdJwt
    }

    return sdJwt + jws
  }

  // MARK: Private

  @Injected(\.sha256Hasher) private var sha256Hasher: Hashable
  @Injected(\.jwsEncoder) private var jwsEncoder: JWSEncoderProtocol

  private func generateKeyBindingJWS(from sdJwt: String, requestObject: RequestObject, keyPair: VaultKeyPair) throws -> String? {
    guard let sdJwtData = sdJwt.data(using: .utf8) else {
      return nil
    }

    let sdJWTsha256 = sha256Hasher.hash(sdJwtData)
    let sdHash = sdJWTsha256.base64URLEncodedString()
    let jwt = KeyBindingJWT(sdHash: sdHash, audience: requestObject.clientId, nonce: requestObject.nonce)
    let data = try jwsEncoder.encode(jwt, using: keyPair)
    return String(data: data, encoding: .utf8)
  }

}
