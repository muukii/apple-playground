import SwiftUI

import SwiftUI

private struct _Book: View {
  
  @State var text: String = "Hello"
  
  var body: some View {
    VStack {      
      TextEditor(text: $text)      
        .scrollContentBackground(.hidden)
        .background(.green)
        .fixedSize()
    }
  }
}

#Preview("Text") {
  _Book()
}
