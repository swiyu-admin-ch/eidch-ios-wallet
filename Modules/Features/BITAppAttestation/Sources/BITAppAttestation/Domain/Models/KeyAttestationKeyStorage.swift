/// Attack Potential Resistance values as per ISO 18045
///
/// [See OID4VCI](https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0.html#name-attack-potential-resistance)
enum KeyAttestationKeyStorage: String, Codable {
  case iso18045EnhancedBasic = "iso_18045_enhanced-basic"
  case iso18045High = "iso_18045_high"
  case iso18045Moderate = "iso_18045_moderate"
  case iso18045Basic = "iso_18045_basic"
}
