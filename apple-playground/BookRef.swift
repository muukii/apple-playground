import Playgrounds
import Observation

@Observable
class MyModel {
  
  var count: Int = 0
  
  var a: Int = 0
}

func commit<State>(
  _ source: inout State,
  modifier: (inout State) -> Void
) {
  
  modifier(&source)
  
}

#Playground { 
    
  @dynamicMemberLookup
  struct MutatingTransaction<S> {
    
    var source: S
    
    init(source: S) {
      self.source = source
    }
                    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<S, T>) -> T {
      get {
        
        source[keyPath: keyPath]
      }
      set {
        
        source[keyPath: keyPath] = newValue    
        
      }
    }
        
  }

  struct S {
    var count: Int 
    var a: Int
  }
    
  let s = S(count: 1, a: 1)
  var t = MutatingTransaction(source: s)
  
  t.count
  t.a
  
//  let hasChanged: Bool = 
  
  // ?
  
  print(s.count)
}

struct MyValue {
  
}

struct A {
  var value: MyValue
}

struct B {
  var value: MyValue
}
