import BITAnyCredentialFormat
import BITCrypto
import BITJWT
import BITLocalAuthentication
import BITSdJWT
import BITVault
import Factory
import Foundation

// MARK: - VcSdJwtVpTokenGenerator

struct VcSdJwtVpTokenGenerator: AnyVpTokenGeneratorProtocol {

  // MARK: Internal

  func generate(requestObject: RequestObject, credential: any AnyCredential, keyPair: KeyPair?, fields: [String]) throws -> VpToken {
    guard let vcSdJwt = credential as? VcSdJwt else {
      throw AnyVpTokenGeneratorError.invalidFormat
    }
    let sdJwt = try vcSdJwt.createSelectiveDisclosure(for: fields)
    return if
      let key = keyPair,
      let keyBindingJWT = try generateKeyBindingJWT(from: sdJwt, requestObject: requestObject, keyPair: key)
    {
      sdJwt + keyBindingJWT
    } else {
      sdJwt
    }
  }

  // MARK: Private

  @Injected(\.sha256Hasher) private var sha256Hasher: Hashable
  @Injected(\.jwsEncoder) private var jwsEncoder: JWSEncoderProtocol

  private func generateKeyBindingJWT(from sdJwt: String, requestObject: RequestObject, keyPair: KeyPair) throws -> String? {
    guard let sdJwtData = sdJwt.data(using: .utf8) else {
      return nil
    }

    let sdJWTsha256 = sha256Hasher.hash(sdJwtData)
    let sdHash = sdJWTsha256.base64URLEncodedString()
    let keyBindingPayload = KeyBindingPayload(sdHash: sdHash, nonce: requestObject.nonce)
    let data = try jwsEncoder.encode(keyBindingPayload, using: keyPair)
    return String(data: data, encoding: .utf8)
  }

}
