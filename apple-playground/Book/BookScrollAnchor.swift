import SwiftUI

import SwiftUI

private struct _Book: View {
  
  var body: some View {
    ScrollView {
      
      ForEach(0..<10, id: \.self) { _ in
        Rectangle()
          .frame(height: 30)
      }
      
    }
    .defaultScrollAnchor(.center)
  }
}

#Preview("ScrollAnchor") {
  _Book()
}
