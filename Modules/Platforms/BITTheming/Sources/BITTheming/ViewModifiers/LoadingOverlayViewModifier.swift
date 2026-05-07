import BITL10n
import SwiftUI
import UIKit

// MARK: - LoadingOverlayAccessibility

public struct LoadingOverlayAccessibility {

  // MARK: Lifecycle

  public init(
    initialAnnouncement: String? = L10n.tkGlobalPleasewait,
    longRunningAnnouncement: String? = L10n.tkGlobalStillworking,
    longRunningAnnouncementDelay: Duration = .seconds(10))
  {
    self.initialAnnouncement = initialAnnouncement
    self.longRunningAnnouncement = longRunningAnnouncement
    self.longRunningAnnouncementDelay = longRunningAnnouncementDelay
  }

  // MARK: Public

  public let initialAnnouncement: String?
  public let longRunningAnnouncement: String?
  public let longRunningAnnouncementDelay: Duration

  public static func voiceOver(
    initialAnnouncement: String? = L10n.tkGlobalPleasewait,
    longRunningAnnouncement: String? = L10n.tkGlobalStillworking,
    longRunningAnnouncementDelay: Duration = .seconds(10))
    -> Self
  {
    Self(
      initialAnnouncement: initialAnnouncement,
      longRunningAnnouncement: longRunningAnnouncement,
      longRunningAnnouncementDelay: longRunningAnnouncementDelay)
  }
}

// MARK: - LoadingOverlayViewModifier

public struct LoadingOverlayViewModifier: ViewModifier {

  // MARK: Lifecycle

  public init(
    isPresented: Bool,
    message: String,
    indicatorTint: Color,
    accessibility: LoadingOverlayAccessibility?)
  {
    self.isPresented = isPresented
    self.message = message
    self.indicatorTint = indicatorTint
    self.accessibility = accessibility
  }

  // MARK: Public

  public func body(content: Content) -> some View {
    content
      .accessibilityHidden(isPresented && accessibility != nil)
      .overlay {
        if isPresented {
          ZStack {
            Color.black.opacity(0.35)
              .ignoresSafeArea()

            VStack(spacing: .x3) {
              ProgressView()
                .progressViewStyle(.circular)
                .tint(indicatorTint)
                .controlSize(.large)

              Text(message)
                .font(.custom.body)
                .foregroundStyle(Color.white)
                .multilineTextAlignment(.center)
            }
            .padding(.horizontal, .x6)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(message)
            .accessibilityFocused($isLoadingIndicatorFocused)
          }
          .accessibilityElement(children: .contain)
          .transition(.opacity)
          .onAppear {
            startAccessibilityHandling()
          }
        }
      }
      .onChange(of: isPresented) { _, isPresented in
        guard !isPresented else { return }
        longRunningAnnouncementTask?.cancel()
        longRunningAnnouncementTask = nil
        hasAnnouncedInitialText = false
        hasAnnouncedLongRunningText = false
        isLoadingIndicatorFocused = false
      }
  }

  // MARK: Private

  @State private var hasAnnouncedInitialText = false
  @State private var hasAnnouncedLongRunningText = false
  @State private var longRunningAnnouncementTask: Task<Void, Never>?
  @AccessibilityFocusState private var isLoadingIndicatorFocused: Bool

  private let isPresented: Bool
  private let message: String
  private let indicatorTint: Color
  private let accessibility: LoadingOverlayAccessibility?

  @MainActor
  private func startAccessibilityHandling() {
    announceLoading()
    focusLoadingIndicator()
    scheduleLongRunningAnnouncement()
  }

  @MainActor
  private func announceLoading() {
    guard let accessibility else { return }

    guard UIAccessibility.isVoiceOverRunning else { return }
    guard !hasAnnouncedInitialText else { return }

    hasAnnouncedInitialText = true
    UIAccessibility.post(
      notification: .announcement,
      argument: accessibility.initialAnnouncement ?? message)
  }

  private func focusLoadingIndicator() {
    guard accessibility != nil else { return }
    guard UIAccessibility.isVoiceOverRunning else { return }

    Task { @MainActor in
      try? await Task.sleep(for: .milliseconds(150))
      guard isPresented else { return }
      isLoadingIndicatorFocused = true
      UIAccessibility.post(notification: .screenChanged, argument: nil)
    }
  }

  private func scheduleLongRunningAnnouncement() {
    guard let accessibility else { return }

    guard UIAccessibility.isVoiceOverRunning else { return }
    guard let longRunningAnnouncement = accessibility.longRunningAnnouncement else { return }

    longRunningAnnouncementTask?.cancel()
    longRunningAnnouncementTask = Task { @MainActor in
      try? await Task.sleep(for: accessibility.longRunningAnnouncementDelay)
      guard !Task.isCancelled else { return }
      guard isPresented else { return }
      guard !hasAnnouncedLongRunningText else { return }

      hasAnnouncedLongRunningText = true
      UIAccessibility.post(notification: .announcement, argument: longRunningAnnouncement)
    }
  }
}

// MARK: - View Extension

extension View {
  public func loadingOverlay(
    isPresented: Bool,
    message: String,
    indicatorTint: Color = .white,
    accessibility: LoadingOverlayAccessibility? = .voiceOver())
    -> some View
  {
    modifier(
      LoadingOverlayViewModifier(
        isPresented: isPresented,
        message: message,
        indicatorTint: indicatorTint,
        accessibility: accessibility))
  }
}
