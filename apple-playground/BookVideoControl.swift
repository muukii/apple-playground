import SwiftUI

private struct _Book: View {
  
  @State var isActive: Bool = false
  @Namespace var namespace
  
  var body: some View {
    
    VStack {
      
       
      ZStack(alignment: .bottom) {
        
        if isActive {
          VStack {
            
            Color.clear
              .frame(
                width: 160,
                height: 180
              )
              .matchedGeometryEffect(
                id: "Video",
                in: namespace,
                isSource: true
              )
            
            HStack {
              Circle()
                .frame(
                  width: 60,
                  height: 60
                )
              Circle()
                .frame(
                  width: 60,
                  height: 60
                )
              Circle()
                .frame(
                  width: 60,
                  height: 60
                )
            }
            .transition(.scale)
          }
          
        }
        
        HStack {
          if !isActive {
            Circle()
              .frame(
                width: 60,
                height: 60
              )
              .transition(.scale)
          }
          
          RoundedRectangle(cornerRadius: 20)
            .foregroundStyle(.red)
            .matchedGeometryEffect(
              id: "Video",
              in: namespace,
              properties: isActive ? .frame : [],
              isSource: false
            )
            .frame(
              width: 120,
              height: 160
            )
           
            .onTapGesture {
              withAnimation(.bouncy) {
                isActive.toggle()
              }
            }
          
          if !isActive {
            Circle()
              .frame(
                width: 60,
                height: 60
              )
              .transition(.scale)
          }
          
        }

      }
    }
    .padding()
      
  }
}

#Preview("VideoControl") {
  _Book()
}

