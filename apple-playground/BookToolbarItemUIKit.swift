import UIKit
import SwiftUI

/// A UIKit counterpart to `BookToolbarItem.swift` for comparing navigation bar buttons.
@available(iOS 26.0, *)
final class BookToolbarItemUIKitViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground
    navigationItem.title = "Hello, World!"

    let helloBarButtonItem = UIBarButtonItem(
      title: "Hello",
      primaryAction: UIAction { _ in }
    )
    helloBarButtonItem.tintColor = .systemPink
    helloBarButtonItem.style = .prominent
    navigationItem.rightBarButtonItem = helloBarButtonItem
  }
}

/// Embeds the UIKit navigation controller in a SwiftUI preview.
@available(iOS 26.0, *)
struct BookToolbarItemUIKitPreview: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> UINavigationController {
    UINavigationController(rootViewController: BookToolbarItemUIKitViewController())
  }

  func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
  }
}

@available(iOS 26.0, *)
#Preview("UIKit") {
  BookToolbarItemUIKitPreview()
}
