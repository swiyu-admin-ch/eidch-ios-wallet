import BITSwiyuSharedKMP
import Factory
import Testing
@testable import BITOpenID
@testable import BITSdJWT

// MARK: - SdJwtBatchCredentialConsistencyValidatorTests

@Suite(.serialized)
struct SdJwtBatchCredentialConsistencyValidatorTests {

  // MARK: Internal

  @Test
  func validate_withEmptyBatch_doesNotCallConsistencyChecker() throws {
    try withValidator { validator, consistencyChecker in
      try validator.validate([])

      #expect(consistencyChecker.checkConsistencyLeftRightCallsCount == 0)
    }
  }

  @Test
  func validate_withSingleCredential_doesNotCallConsistencyChecker() throws {
    try withValidator { validator, consistencyChecker in
      try validator.validate([makeCredential(raw: "first")])

      #expect(consistencyChecker.checkConsistencyLeftRightCallsCount == 0)
    }
  }

  @Test
  func validate_withMultipleCredentials_comparesEveryCredentialWithFirst() throws {
    try withValidator { validator, consistencyChecker in
      try validator.validate([
        makeCredential(raw: "first"),
        makeCredential(raw: "second"),
        makeCredential(raw: "third"),
      ])

      assertInvocations(
        consistencyChecker.checkConsistencyLeftRightReceivedInvocations,
        equal: [
          (left: "first", right: "second"),
          (left: "first", right: "third"),
        ])
    }
  }

  @Test(arguments: [SdJwtCredentialConsistencyResult.warn, .error])
  func validate_withNonOkResult_throwsValidationFailed(result: SdJwtCredentialConsistencyResult) throws {
    try assertValidationFailed(for: result)
  }

  // MARK: Private

  private func withValidator(
    result: SdJwtCredentialConsistencyResult = .ok,
    _ body: (SdJwtBatchCredentialConsistencyValidator, SdJwtCredentialConsistencyCheckerProtocolSpy) throws -> Void) throws
  {
    let consistencyChecker = SdJwtCredentialConsistencyCheckerProtocolSpy()
    consistencyChecker.checkConsistencyLeftRightReturnValue = result

    Container.shared.reset()
    Container.shared.sdJwtCredentialConsistencyChecker.register { consistencyChecker }
    defer { Container.shared.reset() }

    try body(SdJwtBatchCredentialConsistencyValidator(), consistencyChecker)
  }

  private func assertValidationFailed(for result: SdJwtCredentialConsistencyResult) throws {
    try withValidator(result: result) { validator, consistencyChecker in
      do {
        try validator.validate([
          makeCredential(raw: "first"),
          makeCredential(raw: "second"),
        ])
        Issue.record("Expected FetchAnyVerifiableCredentialError.validationFailed")
      } catch FetchAnyVerifiableCredentialError.validationFailed {
        let arguments = try #require(consistencyChecker.checkConsistencyLeftRightReceivedArguments)

        #expect(consistencyChecker.checkConsistencyLeftRightCallsCount == 1)
        #expect(arguments.left == "first")
        #expect(arguments.right == "second")
      } catch {
        Issue.record("Expected FetchAnyVerifiableCredentialError.validationFailed, got \(error)")
      }
    }
  }

  private func makeCredential(raw: String) -> VcSdJWS {
    let credential = VcSdJWS.Mock.sample
    return VcSdJWS(
      jws: credential,
      payload: credential.resolvedPayload,
      resolvedJSON: credential.resolvedJSON,
      rawSdJWS: raw,
      digestAlgorithm: credential.digestAlgorithm,
      disclosures: credential.disclosures,
      rawKeyBinding: credential.rawKeyBinding,
      keyIdentifierDid: "did:tdw:example")
  }

  private func assertInvocations(
    _ invocations: [(left: String, right: String)],
    equal expectedInvocations: [(left: String, right: String)])
  {
    #expect(invocations.count == expectedInvocations.count)

    for (invocation, expectedInvocation) in zip(invocations, expectedInvocations) {
      #expect(invocation.left == expectedInvocation.left)
      #expect(invocation.right == expectedInvocation.right)
    }
  }
}
