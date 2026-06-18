//
//  BookInputEditor.swift
//  apple-playground
//
//  Created by Hiroshi Kimura on 2026/06/18.
//

import SwiftUI

private struct _Book: View {

  @State var flag = false
  @State var text: String = ""
  @FocusState var isFocused: Bool
  @Namespace var ns

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 20)
        .onTapGesture {
          isFocused = false
        }
        .frame(height: 300)      
        .foregroundStyle(.green)
        .padding(20)
        .overlay(alignment: .bottomLeading) {                    
          RoundedRectangle(cornerRadius: 20)
            .onTapGesture {
              isFocused = true
            }
            .foregroundStyle(.blue)
            .frame(width: isFocused ? nil : 200, height: 160)
            .overlay {
              TextField(
                "",
                text: $text
              )
              .focused($isFocused)
              .background(.red)
              .opacity(isFocused == false ? 0 : 1)
            }
            .matchedGeometryEffect(
              id: isFocused ? "A" : "",
              in: ns,
              isSource: false
            )
        }
    }
    .safeAreaInset(edge: .bottom) {
      Color.clear
        .frame(height: 200)
        .matchedGeometryEffect(id: "A", in: ns)
    }
    .animation(.snappy, value: isFocused)
  }
}

#Preview("Morph") {
  _Book()
}
