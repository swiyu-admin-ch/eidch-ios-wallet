import Foundation

struct PinCodeSecretMaterial {
  let salt: Data
  let pepperKey: SecKey
  let initialVector: Data
}
