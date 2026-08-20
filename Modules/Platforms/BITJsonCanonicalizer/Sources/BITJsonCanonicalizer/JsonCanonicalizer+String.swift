extension JsonCanonicalizer {
  func canonicalizeString(_ string: String) throws -> String {
    // Per RFC-8785, string values are serialized as-is, with no Unicode normalization.
    // Otherwise, this could brake Proof-of-Possession body hashes for values containing accented characters.
    "\"\(escapeJSONString(string))\""
  }
}
