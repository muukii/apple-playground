import SwiftUI

private struct _Book: View {
  var body: some View {
    ZStack {
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack { 
          GeometryReader { proxy in 
            let _ = print(proxy.safeAreaInsets)
            Rectangle()
              .ignoresSafeArea()
              .onTapGesture {
                print("Hit")
              }
          }
        }
      }   
      .scrollTargetBehavior(.viewAligned)

    }
    .safeAreaInset(edge: .bottom) {
      Rectangle()
        .fill(.blue)
        .frame(height: 100)
        .allowsHitTesting(false)
    }

  }
}

#Preview("KeyboardBackdrop") {
  _Book()
}
