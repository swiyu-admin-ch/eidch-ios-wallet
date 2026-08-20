// MARK: - CredentialDisplayOrder

/// User-facing credential states in the order they should appear (top to bottom).
public enum CredentialDisplayOrder: CaseIterable {
  case readyForActivation
  case active
  case inProgress
  case ghost
  case rejected
}

// MARK: - VerifiableCredential + CredentialDisplayOrder

extension VerifiableCredential {

  // MARK: Public

  public var displayOrder: CredentialDisplayOrder {
    switch progressionState {
    case .unaccepted:
      .readyForActivation
    case .accepted:
      selectedStatus.displayOrder
    }
  }

  // MARK: Private

  private var selectedStatus: CredentialStatus {
    presentableBundleItem?.status ?? .unknown
  }
}

// MARK: - DeferredCredential + CredentialDisplayOrder

extension DeferredCredential {
  public var displayOrder: CredentialDisplayOrder {
    switch progressionState {
    case .inProgress:
      .inProgress
    case .invalid,
         .issuanceFailed:
      .rejected
    }
  }
}

// MARK: - CredentialStatus + CredentialDisplayOrder

extension CredentialStatus {
  fileprivate var displayOrder: CredentialDisplayOrder {
    switch self {
    case .valid:
      .active
    case .notYetValid:
      .inProgress
    case .unknown,
         .unsupported:
      .ghost
    case .businessExpired,
         .expired,
         .revoked,
         .suspended:
      .rejected
    }
  }
}
