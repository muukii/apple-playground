import SwiftUI

/// Shows the SwiftUI and UIKit navigation bar button examples side by side.
@available(iOS 26.0, *)
struct BookToolbarItemComparisonView: View {
  private let previewWidth: CGFloat = 360
  private let previewHeight: CGFloat = 420

  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      VStack(spacing: 8) {
        Text("SwiftUI")
          .font(.headline)

        BookToolbarItemSwiftUI()
          .frame(width: previewWidth, height: previewHeight)
      }

      VStack(spacing: 8) {
        Text("UIKit")
          .font(.headline)

        BookToolbarItemUIKitPreview()
          .frame(width: previewWidth, height: previewHeight)
      }
    }
    .padding()
    .preferredColorScheme(.dark)
  }
}

@available(iOS 26.0, *)
#Preview("SwiftUI and UIKit") {
  BookToolbarItemComparisonView()
}
