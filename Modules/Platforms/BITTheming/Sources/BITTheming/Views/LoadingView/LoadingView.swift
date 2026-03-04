import SwiftUI

public struct LoadingView: View {

  // MARK: Lifecycle

  public init(primary: String, secondary: String, action: Action? = nil, progressViewStyle: ProgressViewStyle = .setup) {
    self.primary = primary
    self.secondary = secondary
    self.action = action
    self.progressViewStyle = progressViewStyle
  }

  // MARK: Public

  public enum ProgressViewStyle {
    case setup
    case infinite
  }

  public struct Action {
    // MARK: Lifecycle

    public init(action: @escaping () -> Void, buttonText: String) {
      self.action = action
      self.buttonText = buttonText
    }

    // MARK: Internal

    let action: () -> Void
    let buttonText: String
  }

  public var body: some View {
    AdaptiveColumnsView(
      primaryContent: {
        Card(
          background: .color(ThemingAssets.Background.secondary.swiftUIColor),
          content: {
            switch progressViewStyle {
            case .setup:
              ProgressBar(image: ThemingAssets.Gradient.gradient3.swiftUIImage, sequence: .setupSequence)
            case .infinite:
              ProgressBar(image: ThemingAssets.Gradient.gradient3.swiftUIImage, sequence: .infiniteRandomSequence)
            }
          })
          .foregroundStyle(ThemingAssets.Brand.Core.white.swiftUIColor)
          .accessibilityHidden(true)
      },
      secondaryContent: {
        VStack(alignment: .leading, spacing: .x6) {
          Text(primary)
            .font(.custom.title)
            .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
            .multilineTextAlignment(.leading)
            .accessibilityPriorityFocus()
            .accessibilityAddTraits(.isHeader)

          Text(secondary)
            .font(.custom.body)
            .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
            .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, .x6)
        .padding(.bottom)
      },
      footer: {
        if let action, showAction {
          Button(action: action.action) {
            Text(action.buttonText)
              .multilineTextAlignment(.leading)
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.primary)
          .controlSize(.large)
          .padding(.horizontal, .x6)
        }
      })
      .navigationBarBackButtonHidden()
      .toolbar(.visible)
      .task {
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        showAction = true
      }
  }

  // MARK: Private

  @State private var showAction = false

  private let primary: String
  private let secondary: String
  private let action: Action?
  private let progressViewStyle: ProgressViewStyle
}

#Preview {
  LoadingView(primary: "primary", secondary: "secondary")
}
