import NavigatorUI

/// A user-triggered action performed with the current `Navigator`.
///
/// Isolated to the main actor because these are invoked from SwiftUI button actions. Spelling the
/// isolation into the type is what lets the closure bodies touch view-model state directly, instead
/// of asserting it with `MainActor.assumeIsolated` at every call site.
public typealias NavigatorAction = @MainActor (Navigator) -> Void

/// Async variant of ``NavigatorAction``, used by the `primaryAsync` / `secondaryAsync` actions.
public typealias AsyncNavigatorAction = @MainActor (Navigator) async -> Void

/// A user-triggered action that does not need the `Navigator`.
public typealias VoidAction = @MainActor () -> Void
