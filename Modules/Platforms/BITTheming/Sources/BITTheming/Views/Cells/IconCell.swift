import SwiftUI

// MARK: - IconCell

public struct IconCell: View {

  // MARK: Lifecycle

  public init(image: Image? = nil, text: String, disclosureIndicator: DisclosureIndicator = .none, onTap: (() -> Void)? = nil) {
    self.image = image
    self.text = text
    self.disclosureIndicator = disclosureIndicator.image
    self.onTap = onTap
  }

  // MARK: Public

  public var body: some View {
    HStack(alignment: .center, spacing: .x3) {
      if let image {
        image
          .frame(width: Const.iconFrame)
          .accessibility(hidden: true)
      }
      HStack(alignment: .firstTextBaseline) {
        Text(text)

        Spacer(minLength: .x2)

        if let disclosureIndicator {
          disclosureIndicator
            .font(.system(size: 14))
        }
      }
    }
    .onTapGesture {
      onTap?()
    }
    .accessibilityElement(children: .combine)
    .accessibilityAddTraits(.isButton)
    .accessibilityLabel(text)
  }

  // MARK: Internal

  enum Const {
    static let iconFrame: CGFloat = 25
    static let spacingHStack = CGFloat.x5
  }

  // MARK: Private

  private var image: Image?
  private var text: String
  private var disclosureIndicator: Image?
  private var onTap: (() -> Void)?

}

#Preview {
  List {
    IconCell(image: Image(systemName: "42.circle"), text: "Test", disclosureIndicator: .navigation)
  }
}
