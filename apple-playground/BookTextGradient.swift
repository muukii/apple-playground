//
//  BookTextGradient.swift
//  apple-playground
//
//  Created by Hiroshi Kimura on 2026/06/19.
//

import SwiftUI

private struct _Book: View {

  var body: some View {
    Text("Hello")
      .foregroundStyle(
        LinearGradient(
          colors: [.red, .blue],
          startPoint: .leading,
          endPoint: .trailing
        )
      )
  }
}

#Preview("Gradient") {
  _Book()
}
