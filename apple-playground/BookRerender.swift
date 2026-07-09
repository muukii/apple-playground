import SwiftUI

private struct _Book: View {
  
  @State var count1: Int = 0
  @State var count2: Int = 0
  
  var body: some View {
    VStack {
      Nested(value: count1)
      Text(count2.description)
      Button("Up 1") {
        count1 += 1
      }
      Button("Up 2") {
        count2 += 1
      }
    }
  }
}

private struct Nested: View {
  
  let value: Int
  
  var body: some View {
    let _ = print("[Nested] render")
    Text(value.description)
  }
}

#Preview("Rerender") {
  _Book()
}

