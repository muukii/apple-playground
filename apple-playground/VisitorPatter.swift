import Playgrounds

enum Value {
  case text(String)
  case number(Int)  
}

struct Node {
  let value: Value
  var children: [Node]
}

let root = Node(
  value: .text("root"),
  children: [
    Node(
      value: .text("header"),
      children: [
        Node(
          value: .text("title"),
          children: [
            Node(value: .text("Hello"), children: [])
          ]
        )
      ]
    ),
    Node(
      value: .text("main"),
      children: [
        Node(
          value: .text("count"),
          children: [
            Node(value: .number(42), children: [])
          ]
        ),
        Node(
          value: .text("message"),
          children: [
            Node(value: .text("Hello, Swift!"), children: [])
          ]
        )
      ]
    )
  ]
)

class NodeVisitor {
  
  init() {
    
  }
  
  func visit(node: Node) {
       
    switch node.value {
    case .text(let string):
      visit(string: string)
    case .number(let number):
      visit(number: number)
    }
    
    for child in node.children {
      visit(node: child)
    }
    
  }
  
  func visit(string: String) {
    
  }
  
  func visit(number: Int) {
    
  }
  
}

final class StringCountVisitor: NodeVisitor {
  
  var count: Int = 0
  
  override func visit(string: String) {
    
    count += string.count
    
    super.visit(string: string)
  }
  
}

final class NumberCountVisitor: NodeVisitor {
  
  var maxNumber: Int = 0
    
  override func visit(number: Int) {
    maxNumber = max(maxNumber, number)
  }
  
}

#Playground { 
  
  let visitor = StringCountVisitor()
  
  visitor.visit(node: root)
  
  print(visitor.count)
  
}

#Playground { 
  
  let visitor = NumberCountVisitor()
  
  visitor.visit(node: root)
  
  print(visitor.maxNumber)
  
}
