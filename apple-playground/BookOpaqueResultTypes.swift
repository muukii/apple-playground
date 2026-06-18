import Combine
import SwiftUI

public struct AAABook: View {

  public var body: some View {
    MyComp()
  }
  
  private struct MyComp: View {
    var body: some View {
      EmptyView()
    }
  }
}

struct Hoge: View {
  
  var body: some View {
    VStack {
      Text("Hello")
      Text("Hello")
      Text("Hello")
    }
  }
}

#Preview("Hoge") {
  AAABook()   
}
