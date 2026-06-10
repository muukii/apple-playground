import SwiftUI
import Observation
import Combine

private struct _Book: View {
  
  let state: ExternalStore<Int>
  
  var body: some View {
    
    let _ = Self._printChanges()
    
    VStack {
      Text("\(state.value)")
      Button("Up") {
        state.value += 1
      }
    }
    .onAppear {
      
      withObservationTracking { 
        _ = state.value
      } onChange: { 
        print("updated")       
      }
      
      Task {
        if #available(iOS 26.0, *) {
          let stream = Observations { 
            state.value
          }
          
          for await e in stream  {
            print(e)
          }
        } else {
          // Fallback on earlier versions
        }
      
      }
            
    }
  }
  
}

private final class ExternalStore<T>: Observable {
  
  var value: T {
    get {
      registrar.access(self, keyPath: \.value)
      return _value
    }
    set {
      registrar.willSet(self, keyPath: \.value)
      _value = newValue
    }
  }
  
  var _value: T
  var value_1: T
  
  init(_ value: T) {
    self._value = value
    self.value_1 = value        
  }
    
  private let registrar = ObservationRegistrar.init()
  
}

#Preview("Book") {
  _Book(state: .init(0))
}

