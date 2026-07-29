
import Playgrounds
import Combine

#Playground {
  
  func double(_ x: Int) -> Int {
      x * 2
  }
      
  let number: Int? = 3
  
  let doubled: Int? = number.map(
    double
  )
      
}

#Playground {
  
  let subject = PassthroughSubject<Int, Never>()
  
  subject
    .map {
      $0 + 1
    }
    .filter {
      $0 > 2
    }
   
}

#Playground {
    
  let optional: Optional<Int> = .some(1)

  let array: Array<Int> = [1, 2, 3, 4]
  	  
  func makeUI(cornerRadius: Double) {
    
  }
 
  do {
    
    func entry(cornerRadius: Double?) {
      
      let resolved: Double
      if let cornerRadius {
        resolved = cornerRadius * 2
      } else {
        resolved = 0
      }
      
      let _ = cornerRadius != nil ? cornerRadius! * 2 : 0
      
      let _ = (cornerRadius ?? 0) * 2
      
      let _ = cornerRadius.map { $0 * 2 } ?? 0
                  
      makeUI(cornerRadius: cornerRadius ?? 12)
      
    }
    
    entry(cornerRadius: nil)
    
    optional
      .map {
        $0 + 1
      }
  }
  
  do {  
    
    
    let r = array
      .map {
        $0 + 1
      }
      .filter {
        $0 > 2
      }
      .reduce(into: 0) { partialResult, element in
        partialResult += element
      }

    print(r)
  }
  
}

#Playground {
  
  let source = [1,2,3]
  
  let r = source    
    .map {
      [$0]
    }
//    .map { 
//      if $0 > 2 {
//        return $0
//      } else {
//        return nil 
//      }
//    }
    .flatMap { $0 }
  
}
