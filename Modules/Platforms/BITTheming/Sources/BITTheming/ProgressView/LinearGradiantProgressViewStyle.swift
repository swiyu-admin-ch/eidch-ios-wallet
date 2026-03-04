import SwiftUI

// MARK: - LinearGradientStyle

extension ProgressViewStyle where Self == LinearGradientProgressViewStyle {
  @MainActor @preconcurrency public static var linearGradient: LinearGradientProgressViewStyle {
    LinearGradientProgressViewStyle()
  }
}

// MARK: - LinearGradientProgressViewStyle

public struct LinearGradientProgressViewStyle: ProgressViewStyle {

  // MARK: Public

  public func makeBody(configuration: Configuration) -> some View {
    let progress = (configuration.fractionCompleted ?? 0.0)

    VStack(alignment: .leading, spacing: 8) {
      configuration.label
        .font(.custom.body)

      ZStack(alignment: .leading) {
        RoundedRectangle(cornerRadius: height)
          .fill(ThemingAssets.Brand.Accent.purple.swiftUIColor)

        GeometryReader { geo in
          RoundedRectangle(cornerRadius: height)
            .fill(color)
            .frame(width: geo.size.width * progress)
        }
      }
      .frame(height: height)
      .frame(maxWidth: .infinity)
      .clipped()

      if let currentValueLabel = configuration.currentValueLabel {
        HStack {
          Spacer()
          currentValueLabel
            .font(.custom.body)
        }
      }
    }
    .fixedSize(horizontal: false, vertical: true)
  }

  // MARK: Internal

  let color = LinearGradient(
    colors: [
      ThemingAssets.Brand.Accent.pink.swiftUIColor.opacity(0.5),
      ThemingAssets.Brand.Accent.pink.swiftUIColor,
    ],
    startPoint: .leading,
    endPoint: .trailing)

  let height: CGFloat = 8
}
