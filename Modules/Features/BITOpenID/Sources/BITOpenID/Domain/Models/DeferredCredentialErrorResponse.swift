struct DeferredCredentialErrorResponse: Codable {

  // MARK: Internal

  enum Code: String, Codable {
    case issuancePending = "ISSUANCE_PENDING"
    case invalidTransactionId = "INVALID_TRANSACTION_ID"
  }

  let error: Code
  let interval: Int?

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case error
    case interval
    case errorDescription = "error_description"
  }

  private let errorDescription: String

}
