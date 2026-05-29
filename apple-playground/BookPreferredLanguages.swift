import Playgrounds
import SwiftUI

private struct _Book: View {

  var body: some View {

    build {

      Locale.preferredLanguages

    }
    .onAppear {
      print(Locale.preferredLanguages)
    }
  }
}

#Preview("PreferredLanguages") {
  _Book()
}

#Playground {
  Locale.Language(identifier: "ja-JP")
  Locale.Language(identifier: "ja")
}

@resultBuilder
public enum PlaygroundResultBuilder {

  public static func buildBlock(_ components: Any...) -> [Any] {
    return components
  }

  public static func buildFinalResult(_ component: [Any]) -> some View {
    let lines = component.map {
      String(describing: $0)
    }
    return Group {
      LazyVStack {
        ForEach(lines, id: \.self) { line in
          Text(line)
        }
      }
    }
  }

}

func build(@PlaygroundResultBuilder build: () -> some View) -> some View {
  return build()
}
