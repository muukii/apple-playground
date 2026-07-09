
import SwiftUI

private struct _Book: View {
  
  @State var count: Int = 0
  
  var body: some View {
    Button("Run") {
      count += 1
    }
    .task(id: count) { 
      
      await withTaskCancellationHandler { 
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
      } onCancel: { 
        print("cancelled")
      }
      
      print("done")

    }
  }
}

private func doSomething() async -> Int {
  try? await Task.sleep(for: .seconds(2))
  return 1
}

#Preview("BookCancellation") {
  _Book()
}
