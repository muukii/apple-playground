import SwiftUI

/// A SwiftUI navigation bar button for comparing its appearance with UIKit.
@available(iOS 26.0, *)
struct BookToolbarItemSwiftUI: View {
  var body: some View {
    NavigationStack {
      ScrollView {
        // ScrollView content
      }
      .navigationTitle("Hello, World!")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button(role: .confirm) {
            
          } label: {
            Label { 
              Text("send")
            } icon: { 
              Image(systemName: "arrow.up")
            }

          }
        }
      }
    }
  }
}

@available(iOS 26.0, *)
#Preview("SwiftUI") {
  BookToolbarItemSwiftUI()
}
