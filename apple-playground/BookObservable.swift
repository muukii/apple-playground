import SwiftUI

private struct _Book: View {
  
  let model = Model(count: 1)
  
  var body: some View {
    VStack {
      
      Button("Up") {
        model.count += 1
      }
      Representable(model: model)
    }
  }
}

@Observable
private final class Model {
  var count: Int
  init(count: Int) {
    self.count = count
  }
}

private struct Representable: UIViewRepresentable {
  
  let model: Model

  func makeUIView(context: Context) -> UIView {
    let view = UIView()
    return view
  }  
  
  func updateUIView(_ uiView: UIView, context: Context) {
//    let _ = model.count
    
    print("update")
  }
}

#Preview("Observable") {
  _Book()
}

