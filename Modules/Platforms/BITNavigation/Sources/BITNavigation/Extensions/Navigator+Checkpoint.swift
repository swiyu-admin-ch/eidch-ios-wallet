import NavigatorUI

extension Navigator {
  @MainActor
  public func returnToCheckpointSafely<T: Hashable>(_ checkpoint: NavigationCheckpoint<T>, value: T) {
    returnToCheckpoint(checkpoint, value: value)
    if parent?.canReturnToCheckpoint(checkpoint) == true {
      dismiss()
    }
  }

  @MainActor
  public func returnToCheckpointSafely(_ checkpoint: NavigationCheckpoint<some Any>) {
    returnToCheckpoint(checkpoint)
    if parent?.canReturnToCheckpoint(checkpoint) == true {
      dismiss()
    }
  }
}
