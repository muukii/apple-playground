//
//  BookAlignment.swift
//  apple-playground
//
//  Created by Hiroshi Kimura on 2026/06/19.
//

import SwiftUI

private struct _Book: View {

  var body: some View {
    ZStack {
      VStack {
        Rectangle()
          .frame(width: 200, height: 200)
        
        Button("H") {}
      }
    }
    .overlay(alignment: .bottomLeading) {
      Rectangle()
        .foregroundStyle(.blue)
        .frame(width: 50, height: 60)
        .alignmentGuide(.bottom) { d in
          d[.top]
        }
    }

  }
}

#Preview("Alignment") {
  _Book()
}
