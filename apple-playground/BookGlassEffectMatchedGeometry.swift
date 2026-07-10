import SwiftUI

/// Demonstrates a Liquid Glass shape morphing from a nearby, existing shape.
///
/// `GlassEffectTransition.matchedGeometry` differs from
/// `matchedGeometryEffect(id:in:)`: the two views use unique glass effect IDs.
/// SwiftUI chooses a nearby glass shape in the same container as the geometry
/// source for a shape that is being inserted or removed.
@available(iOS 26.0, *)
private struct GlassEffectMatchedGeometryExample: View {

  var body: some View {
    ZStack {
      GlassExampleBackdrop()

      VStack(spacing: 24) {
        GlassExampleHeader()

        Spacer()

        GlassTransitionToolbar()

        Text("The palette is close enough to morph from the circular button.")
          .font(.footnote)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
      }
      .padding(28)
    }
  }
}

@available(iOS 26.0, *)
private struct GlassExampleHeader: View {

  var body: some View {
    VStack(spacing: 8) {
      Text("Matched Glass Geometry")
        .font(.title.bold())

      Text("Tap the circular button to add or remove a glass tool palette.")
        .font(.body)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }
  }
}

/// Owns the view-hierarchy change that triggers the glass transition.
@available(iOS 26.0, *)
private struct GlassTransitionToolbar: View {

  @State private var isExpanded = false
  @State private var selectedTool: GlassTool = .draw
  @Namespace private var glassNamespace

  var body: some View {
    GlassEffectContainer(spacing: 20) {
      HStack(spacing: 20) {
        if isExpanded {
          GlassToolPalette(
            selectedTool: selectedTool,
            namespace: glassNamespace,
            onSelect: { selectedTool = $0 }
          )
        }

        Button {
          withAnimation(.spring(duration: 0.45, bounce: 0.28)) {
            isExpanded.toggle()
          }
        } label: {
          Image(systemName: isExpanded ? "xmark" : "paintbrush.pointed.fill")
            .font(.title3.weight(.semibold))
            .frame(width: 56, height: 56)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: Circle())
        .glassEffectID("palette-toggle", in: glassNamespace)
        .accessibilityLabel(isExpanded ? Text("Close tools") : Text("Open tools"))
      }
    }
  }
}

/// The inserted glass shape that derives its transition geometry from the
/// nearby toggle button.
@available(iOS 26.0, *)
private struct GlassToolPalette: View {

  let selectedTool: GlassTool
  let namespace: Namespace.ID
  let onSelect: @MainActor @Sendable (GlassTool) -> Void

  var body: some View {
    HStack(spacing: 4) {
      ForEach(GlassTool.allCases) { tool in
        Button {
          onSelect(tool)
        } label: {
          Image(systemName: tool.symbolName)
            .font(.body.weight(.semibold))
            .foregroundStyle(selectedTool == tool ? Color.accentColor : Color.primary)
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(tool.accessibilityTitle))
        .accessibilityAddTraits(selectedTool == tool ? .isSelected : [])
      }
    }
    .padding(.horizontal, 6)
    .padding(.vertical, 6)
    .glassEffect(.regular.interactive(), in: Capsule())
    .glassEffectID("tool-palette", in: namespace)
    // The unique ID identifies this glass shape. It intentionally does not
    // match the toggle ID; proximity inside the container supplies the source.
    .glassEffectTransition(.matchedGeometry)
  }
}

/// A selectable tool displayed inside the example palette.
private enum GlassTool: String, CaseIterable, Identifiable, Sendable {
  case draw
  case erase
  case highlight

  /// Stable identity used by the palette's `ForEach`.
  var id: Self { self }

  /// The SF Symbol representing the tool.
  var symbolName: String {
    switch self {
    case .draw:
      "pencil.tip"
    case .erase:
      "eraser.fill"
    case .highlight:
      "highlighter"
    }
  }

  /// The localized VoiceOver label for the tool.
  var accessibilityTitle: LocalizedStringResource {
    switch self {
    case .draw:
      "Draw"
    case .erase:
      "Erase"
    case .highlight:
      "Highlight"
    }
  }
}

@available(iOS 26.0, *)
private struct GlassExampleBackdrop: View {

  var body: some View {
    ZStack {
      Color(.systemBackground)

      Circle()
        .fill(.purple.opacity(0.28))
        .frame(width: 280, height: 280)
        .blur(radius: 18)
        .offset(x: -150, y: -260)

      Circle()
        .fill(.cyan.opacity(0.24))
        .frame(width: 320, height: 320)
        .blur(radius: 24)
        .offset(x: 170, y: 250)
    }
    .ignoresSafeArea()
  }
}

#Preview("Glass matched geometry") {
  if #available(iOS 26.0, *) {
    GlassEffectMatchedGeometryExample()
  } else {
    ContentUnavailableView(
      "Requires iOS 26",
      systemImage: "sparkles",
      description: Text("Liquid Glass transitions are available on iOS 26 and later.")
    )
  }
}
