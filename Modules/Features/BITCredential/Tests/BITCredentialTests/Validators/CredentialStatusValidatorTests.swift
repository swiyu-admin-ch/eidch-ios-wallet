// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

import Factory
import Foundation
import Testing
@testable import BITAnyCredentialFormat
@testable import BITCore
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITTestingCore

// MARK: - CredentialStatusValidatorTests

@Suite
struct CredentialStatusValidatorTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()
    registerMocks()
    createSuccessState()
    validator = CredentialStatusValidator()
  }

  // MARK: Internal

  @Test
  func callAsFunction_argumentsPassed() async throws {
    _ = try await validator(credentialMock)

    #expect(selectCredentialBundleItemUseCase.callAsFunctionCallsCount == 1)
    #expect(selectCredentialBundleItemUseCase.callAsFunctionReceivedCredential == credentialMock)

    #expect(createAnyCredentialUseCase.executeFromFormatCallsCount == 1)
    #expect(createAnyCredentialUseCase.executeFromFormatReceivedArguments?.payload == credentialMock.bundleItems.first?.payload)
    #expect(createAnyCredentialUseCase.executeFromFormatReceivedArguments?.format == credentialMock.format)

    #expect(statusValidator.validateIssuerCallsCount == 1)
    #expect(statusValidator.validateIssuerReceivedArguments?.anyStatus.type == Self.statusMock.type)
    #expect(statusValidator.validateIssuerReceivedArguments?.issuer == Self.issuerMock)
  }

  @Test
  func callAsFunction_valid_returnsValid() async throws {
    statusValidator.validateIssuerReturnValue = .valid

    let result = try await validator(credentialMock)

    #expect(result == .valid)
  }

  @Test
  func callAsFunction_suspended_returnsSuspended() async throws {
    statusValidator.validateIssuerReturnValue = .suspended

    let result = try await validator(credentialMock)

    #expect(result == .suspended)
  }

  @Test
  func callAsFunction_revoked_returnsRevoked() async throws {
    statusValidator.validateIssuerReturnValue = .revoked

    let result = try await validator(credentialMock)

    #expect(result == .revoked)
  }

  @Test
  func callAsFunction_unsupported_returnsUnsupported() async throws {
    statusValidator.validateIssuerReturnValue = .unsupported

    let result = try await validator(credentialMock)

    #expect(result == .unsupported)
  }

  @Test
  func callAsFunction_unknownValidatorStatus_returnsUnknown() async throws {
    statusValidator.validateIssuerReturnValue = .unknown

    let result = try await validator(credentialMock)

    #expect(result == .unknown)
  }

  @Test
  func callAsFunction_noStatus_returnsUnknown() async throws {
    createAnyCredentialUseCase.executeFromFormatReturnValue = mockAnyCredential(status: nil)

    let result = try await validator(credentialMock)

    #expect(result == .unknown)
    #expect(!statusValidator.validateIssuerCalled)
  }

  @Test
  mutating func callAsFunction_noValidator_returnsUnknown() async throws {
    Container.shared.statusValidators.register { [:] }
    validator = CredentialStatusValidator()

    let result = try await validator(credentialMock)

    #expect(result == .unknown)
  }

  @Test
  func callAsFunction_justNotExpired_returnsValid() async throws {
    createAnyCredentialUseCase.executeFromFormatReturnValue = mockAnyCredential(validUntil: Self.testDate)

    let result = try await validator(credentialMock)

    #expect(result == .valid)
  }

  @Test
  func callAsFunction_expired_returnsExpired() async throws {
    createAnyCredentialUseCase.executeFromFormatReturnValue = mockAnyCredential(validUntil: Self.testDate.addingTimeInterval(-1))

    let result = try await validator(credentialMock)

    #expect(result == .expired)
    #expect(!statusValidator.validateIssuerCalled)
  }

  @Test
  func callAsFunction_validFromWithinBuffer_returnsValid() async throws {
    createAnyCredentialUseCase.executeFromFormatReturnValue = mockAnyCredential(validFrom: Self.testDate.addingTimeInterval(Self.buffer))

    let result = try await validator(credentialMock)

    #expect(result == .valid)
  }

  @Test
  func callAsFunction_validFromOutsideBuffer_returnsNotYetValid() async throws {
    createAnyCredentialUseCase.executeFromFormatReturnValue = mockAnyCredential(validFrom: Self.testDate.addingTimeInterval(Self.buffer + 1))

    let result = try await validator(credentialMock)

    #expect(result == .notYetValid)
  }

  @Test
  func callAsFunction_notYetValidAndRevoked_returnsRevoked() async throws {
    createAnyCredentialUseCase.executeFromFormatReturnValue = mockAnyCredential(validFrom: Self.testDate.addingTimeInterval(Self.buffer) + 1)
    statusValidator.validateIssuerReturnValue = .revoked

    let result = try await validator(credentialMock)

    #expect(result == .revoked)
  }

  @Test
  mutating func callAsFunction_justNotBusinessExpired_returnsValid() async throws {
    let startOfDay = Self.testDate.startOfDayInUTC
    Container.shared.currentDate.register { startOfDay.addingTimeInterval(.days(1)) }
    createAnyCredentialUseCase.executeFromFormatReturnValue = VcSdJWS.Mock.create(expiryDate: startOfDay.businessFormatted)
    validator = CredentialStatusValidator()

    let result = try await validator(credentialMock)

    #expect(result == .valid)
  }

  @Test
  mutating func callAsFunction_businessExpired_returnsBusinessExpired() async throws {
    let startOfDay = Self.testDate.startOfDayInUTC
    Container.shared.currentDate.register { startOfDay.addingTimeInterval(.days(1) + 1) }
    createAnyCredentialUseCase.executeFromFormatReturnValue = VcSdJWS.Mock.create(expiryDate: startOfDay.businessFormatted)
    validator = CredentialStatusValidator()

    let result = try await validator(credentialMock)

    #expect(result == .businessExpired)
  }

  @Test
  mutating func callAsFunction_businessExpiredAndRevoked_returnsRevoked() async throws {
    let startOfDay = Self.testDate.startOfDayInUTC
    Container.shared.currentDate.register { startOfDay.addingTimeInterval(.days(1) + 1) }
    createAnyCredentialUseCase.executeFromFormatReturnValue = VcSdJWS.Mock.create(expiryDate: startOfDay.businessFormatted)
    statusValidator.validateIssuerReturnValue = .revoked
    validator = CredentialStatusValidator()

    let result = try await validator(credentialMock)

    #expect(result == .revoked)
  }

  @Test
  func callAsFunction_selectBundleItemThrows_rethrowsError() async {
    selectCredentialBundleItemUseCase.callAsFunctionThrowableError = TestingError.error

    await #expect(throws: TestingError.self) {
      _ = try await validator(credentialMock)
    }
  }

  @Test
  func callAsFunction_createAnyCredentialThrows_rethrowsError() async {
    createAnyCredentialUseCase.executeFromFormatThrowableError = TestingError.error

    await #expect(throws: TestingError.self) {
      _ = try await validator(credentialMock)
    }
  }

  // MARK: Private

  private static let buffer: TimeInterval = 5
  private static let testDate = Date(timeIntervalSince1970: 1_700_000_000)
  private static let issuerMock = "issuer"

  private static let statusMock = AnyStatusSpy()

  private let credentialMock = VerifiableCredential.Mock.sample
  private var anyCredentialMock: AnyCredentialSpy!
  private let sdJwtCredentialMock = VcSdJWS.Mock.sample

  private var validator: CredentialStatusValidator!

  private var createAnyCredentialUseCase: CreateAnyCredentialUseCaseProtocolSpy!
  private var selectCredentialBundleItemUseCase: SelectCredentialBundleItemUseCaseProtocolSpy!
  private var statusValidator: AnyStatusCheckValidatorProtocolSpy!

  private mutating func registerMocks() {
    Self.statusMock.type = .tokenStatusList
    anyCredentialMock = mockAnyCredential(status: Self.statusMock)

    let createAnyCredentialUseCase = CreateAnyCredentialUseCaseProtocolSpy()
    let selectCredentialBundleItemUseCase = SelectCredentialBundleItemUseCaseProtocolSpy()
    let statusValidator = AnyStatusCheckValidatorProtocolSpy()

    self.createAnyCredentialUseCase = createAnyCredentialUseCase
    self.selectCredentialBundleItemUseCase = selectCredentialBundleItemUseCase
    self.statusValidator = statusValidator

    Container.shared.createAnyCredentialUseCase.register { createAnyCredentialUseCase }
    Container.shared.selectCredentialBundleItemUseCase.register { selectCredentialBundleItemUseCase }
    Container.shared.statusValidators.register { [.tokenStatusList: statusValidator] }

    Container.shared.dateBuffer.register { Self.buffer }
    Container.shared.currentDate.register { Self.testDate }
  }

  private func mockAnyCredential(status: AnyStatus? = statusMock, issuer: String = issuerMock, validFrom: Date? = nil, validUntil: Date? = nil) -> AnyCredentialSpy {
    let credential = AnyCredentialSpy()
    credential.status = status
    credential.issuer = issuer
    credential.validFrom = validFrom
    credential.validUntil = validUntil
    return credential
  }

  private func createSuccessState() {
    selectCredentialBundleItemUseCase.callAsFunctionClosure = {
      guard let item = $0.bundleItems.first else { throw CredentialError.noBundleItem }
      return item
    }
    createAnyCredentialUseCase.executeFromFormatReturnValue = anyCredentialMock
    statusValidator.validateIssuerReturnValue = .valid
  }
}

extension Date {
  fileprivate var businessFormatted: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(identifier: "UTC")
    return formatter.string(from: self)
  }

  fileprivate var startOfDayInUTC: Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    return calendar.startOfDay(for: self)
  }
}
