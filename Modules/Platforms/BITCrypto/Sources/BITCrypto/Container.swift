import Factory

extension Container {

  // MARK: Public

  public var pbkdf2Configuration: Factory<PBKDF2.Configuration> {
    self {
      PBKDF2.Configuration(
        iterations: self.pbkdf2NumberOfIterations(),
        keyLength: self.pbkdf2KeyLength())
    }
  }

  public var sriValidator: Factory<SRIValidatorProtocol> {
    self { SRIValidator() }
  }

  public var jweEncrypter: Factory<JWEEncrypterProtocol> {
    self { JWEEncrypter() }
  }

  public var jweDecrypter: Factory<JWEDecrypterProtocol> {
    self { JWEDecrypter() }
  }

  public var sha256Hasher: Factory<Hashable> {
    self { SHA256Hasher() }
  }

  // MARK: Private

  /// The number of iterations for the PBKDF2 function.
  ///
  /// While NIST recommends a minimum of 10,000 iterations, the CryptoSwift library currently used for PBKDF2
  /// does not leverage hardware acceleration. Based on performance testing, 1,000 iterations already imposes
  /// a significant computational delay (~1 second) on typical devices, satisfying the purpose of a key derivation
  /// function in mitigating brute-force attacks.
  ///
  /// This choice must be reinforced by a second layer of security: encryption using a key stored
  /// in the Secure Enclave. This makes the derived key infeasible to compute on external high-performance systems.
  private var pbkdf2NumberOfIterations: Factory<Int> {
    self { 1000 }
  }

  private var pbkdf2KeyLength: Factory<Int> {
    self { 64 }
  }

}
