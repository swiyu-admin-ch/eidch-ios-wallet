import BITL10n
import SwiftUI
import UIKit

// MARK: - EmptyStateView

public struct EmptyStateView<Label>: View where Label: View {

  // MARK: Lifecycle

  public init(_ state: State, @ViewBuilder label: @escaping () -> Label? = { nil }) {
    self.state = state
    self.label = label
  }

  public init(_ state: State, @ViewBuilder label: @escaping () -> Label, action: @escaping () async -> Void) {
    self.state = state
    self.action = action
    self.label = label
  }

  // MARK: Public

  public enum State {
    case error(error: Error?)
    case errorCustom(title: String?, message: String?)
    case offline
    case empty
    case success(title: String?, message: String?)
    case custom(title: String?, message: String?, image: Image?, imageColor: Color?)

    // MARK: Internal

    var title: String? {
      switch self {
      case .error:
        L10n.emptyStateErrorTitle
      case .custom(let title, _, _, _),
           .errorCustom(let title, _),
           .success(let title, _):
        title
      case .offline:
        L10n.emptyStateOfflineTitle
      case .empty:
        L10n.emptyStateEmptyTitle
      }
    }

    var message: String? {
      switch self {
      case .error(let error):
        error?.localizedDescription ?? ""
      case .errorCustom(_, let message):
        message
      case .offline:
        L10n.emptyStateOfflineMessage
      case .empty:
        nil
      case .success(_, let message):
        message
      case .custom(_, let message, _, _):
        message
      }
    }

    var image: Image? {
      switch self {
      case .error,
           .errorCustom:
        Image(systemName: "exclamationmark.triangle")
      case .offline:
        Image(systemName: "wifi.slash")
      case .empty:
        Image(systemName: "lines.measurement.horizontal")
      case .success:
        Image(systemName: "checkmark.circle")
      case .custom(_, _, let image, _):
        image
      }
    }

    var imageColor: Color? {
      switch self {
      case .empty,
           .error,
           .errorCustom,
           .offline:
        .gray
      case .success:
        .green
      case .custom(_, _, _, let color):
        color
      }
    }
  }

  public var body: some View {
    HStack(alignment: .center) {
      VStack(alignment: .center, spacing: .normal) {
        if let image = state.image {
          image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: 64)
            .foregroundColor(state.imageColor)
            .font(.custom.title.weight(.light))
            .padding(.bottom, .x4)
        }

        if let title = state.title {
          Text(title)
            .font(.custom.title)
            .multilineTextAlignment(.center)
        }

        if let message = state.message {
          Text(message)
            .foregroundColor(Color(UIColor.secondaryLabel))
            .multilineTextAlignment(.center)
        }

        if let action {
          Button(action: {
            Task {
              await action()
            }
          }, label: {
            label()
          })
          .buttonStyle(.primary)
          .controlSize(.regular)
        } else {
          label()
        }

      }
    }
    .padding()
  }

  // MARK: Internal

  @ViewBuilder var label: () -> Label?
  var action: (() async -> Void)?

  // MARK: Private

  private var state: State
  private var showButton = false

}

// MARK: - EmptyStateView_Previews

#Preview {
  Group {
    EmptyStateView(.offline) {
      Text("Something")
    } action: {

    }
  }
}
