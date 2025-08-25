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
    guard let vcSdJwt = credential as? VcSdJwt else {
      throw AnyVpTokenGeneratorError.invalidFormat
    }
    let sdJwt = try vcSdJwt.createSelectiveDisclosure(for: fields)

    guard
      let key = keyPair,
      let keyBindingJWT = try generateKeyBindingJWT(from: sdJwt, requestObject: requestObject, keyPair: key)
    else {
      return sdJwt
    }

    return sdJwt + keyBindingJWT
  }

  // MARK: Private

  @Injected(\.sha256Hasher) private var sha256Hasher: Hashable
  @Injected(\.jwsEncoder) private var jwsEncoder: JWSEncoderProtocol

  private func generateKeyBindingJWT(from sdJwt: String, requestObject: RequestObject, keyPair: VaultKeyPair) throws -> String? {
    guard let sdJwtData = sdJwt.data(using: .utf8) else {
      return nil
    }

    let sdJWTsha256 = sha256Hasher.hash(sdJwtData)
    let sdHash = sdJWTsha256.base64URLEncodedString()
    let keyBindingPayload = KeyBindingPayload(sdHash: sdHash, audience: requestObject.clientId, nonce: requestObject.nonce)
    let data = try jwsEncoder.encode(keyBindingPayload, using: keyPair)
    return String(data: data, encoding: .utf8)
  }

}
