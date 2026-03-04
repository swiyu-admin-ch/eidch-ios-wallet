import SwiftUI

extension LabelStyle where Self == TitleAndIconReversedLabelStyle {
  public static var titleAndIconReversed: TitleAndIconReversedLabelStyle {
    TitleAndIconReversedLabelStyle()
  }
}

// MARK: - TitleAndIconReversedLabelStyle

public struct TitleAndIconReversedLabelStyle: LabelStyle {

  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    HStack {
      configuration.title
      configuration.icon
    }
  }

}
