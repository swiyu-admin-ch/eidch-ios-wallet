import SwiftUI
import UIKit

// MARK: - CopyShareMenuModifierString

struct CopyShareMenuModifierString: ViewModifier {
  let text: String
  let shareItem: String

  func body(content: Content) -> some View {
    content.contextMenu {
      Button("Copy") {
        UIPasteboard.general.string = text
      }
      ShareLink(item: shareItem) {
        Label("Share", systemImage: "square.and.arrow.up")
      }
    }
  }
}

// MARK: - CopyShareMenuModifierURL

struct CopyShareMenuModifierURL: ViewModifier {
  let text: String
  let shareItem: URL

  func body(content: Content) -> some View {
    content.contextMenu {
      Button("Copy") {
        UIPasteboard.general.string = text
      }
      ShareLink(item: shareItem) {
        Label("Share", systemImage: "square.and.arrow.up")
      }
    }
  }
}

extension View {
  func copyShareMenu(text: String, shareItem: String) -> some View {
    modifier(CopyShareMenuModifierString(text: text, shareItem: shareItem))
  }

  func copyShareMenu(text: String, shareItem: URL) -> some View {
    modifier(CopyShareMenuModifierURL(text: text, shareItem: shareItem))
  }
}
