import SwiftUI

/// A mask that fades scrollable content at selected edges.
///
/// Use this view directly with `.mask { ... }` when the scroll container is not
/// created by `EdgeEffectScrollView`, such as with `List`.
public struct EdgeEffectMask: View {

  /// The visible fade state for each edge of an `EdgeEffectMask`.
  public struct Visibility: Equatable, Sendable {

    /// Whether the top edge should fade from transparent to visible content.
    public var showsTop: Bool

    /// Whether the bottom edge should fade from visible content to transparent.
    public var showsBottom: Bool

    /// Whether the leading edge should fade from transparent to visible content.
    public var showsLeading: Bool

    /// Whether the trailing edge should fade from visible content to transparent.
    public var showsTrailing: Bool

    public init(
      showsTop: Bool = false,
      showsBottom: Bool = false,
      showsLeading: Bool = false,
      showsTrailing: Bool = false
    ) {
      self.showsTop = showsTop
      self.showsBottom = showsBottom
      self.showsLeading = showsLeading
      self.showsTrailing = showsTrailing
    }

    /// Creates edge visibility by comparing the visible scroll rect with the content bounds.
    public init(
      scrollGeometry geometry: ScrollGeometry,
      edges: Edge.Set = [.top, .bottom],
      threshold: CGFloat = 1
    ) {
      self.init(
        showsTop: edges.contains(.top)
          && geometry.contentOffset.y > geometry.contentInsets.top + threshold,
        showsBottom: edges.contains(.bottom)
          && geometry.visibleRect.maxY < geometry.contentSize.height
            - geometry.contentInsets.bottom
            - threshold,
        showsLeading: edges.contains(.leading)
          && geometry.contentOffset.x > geometry.contentInsets.leading + threshold,
        showsTrailing: edges.contains(.trailing)
          && geometry.visibleRect.maxX < geometry.contentSize.width
            - geometry.contentInsets.trailing
            - threshold
      )
    }
  }

  private let edges: Edge.Set
  private let radius: CGFloat
  private let padding: EdgeInsets
  private let visibility: Visibility

  /// Creates an edge fade mask for a scrollable view.
  ///
  /// - Parameters:
  ///   - edges: The edges where fade ramps can appear.
  ///   - radius: The length of each fade ramp.
  ///   - padding: Fully visible insets before the fade ramps begin.
  ///   - visibility: The current visibility state for each edge fade.
  public init(
    edges: Edge.Set = [.top, .bottom],
    radius: CGFloat = 40,
    padding: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
    visibility: Visibility = Visibility()
  ) {
    self.edges = edges
    self.radius = radius
    self.padding = padding
    self.visibility = visibility
  }

  public var body: some View {
    VStack(spacing: 0) {
      visiblePadding(length: padding.top, edge: .top)

      if edges.contains(.top) {
        fadingEdge(shows: visibility.showsTop) {
          edgeGradient(for: .top)
        }
        .frame(height: fadeLength)
      }

      HStack(spacing: 0) {
        visiblePadding(length: padding.leading, edge: .leading)

        if edges.contains(.leading) {
          fadingEdge(shows: visibility.showsLeading) {
            edgeGradient(for: .leading)
          }
          .frame(width: fadeLength)
        }

        Rectangle()

        if edges.contains(.trailing) {
          fadingEdge(shows: visibility.showsTrailing) {
            edgeGradient(for: .trailing)
          }
          .frame(width: fadeLength)
        }

        visiblePadding(length: padding.trailing, edge: .trailing)
      }

      if edges.contains(.bottom) {
        fadingEdge(shows: visibility.showsBottom) {
          edgeGradient(for: .bottom)
        }
        .frame(height: fadeLength)
      }

      visiblePadding(length: padding.bottom, edge: .bottom)
    }
  }

  private var fadeLength: CGFloat {
    max(radius, 0)
  }

  @ViewBuilder
  private func visiblePadding(length: CGFloat, edge: Edge) -> some View {
    if length > 0 {
      switch edge {
      case .top, .bottom:
        Rectangle()
          .frame(height: length)
      case .leading, .trailing:
        Rectangle()
          .frame(width: length)
      }
    }
  }

  private func edgeGradient(for edge: Edge) -> LinearGradient {
    switch edge {
    case .top:
      return fadingGradient(
        transparentAtStart: true,
        startPoint: .top,
        endPoint: .bottom
      )
    case .leading:
      return fadingGradient(
        transparentAtStart: true,
        startPoint: .leading,
        endPoint: .trailing
      )
    case .bottom:
      return fadingGradient(
        transparentAtStart: false,
        startPoint: .top,
        endPoint: .bottom
      )
    case .trailing:
      return fadingGradient(
        transparentAtStart: false,
        startPoint: .leading,
        endPoint: .trailing
      )
    }
  }

  /// Creates the edge mask ramp, including a short intermediate stop that softens the fade.
  private func fadingGradient(
    transparentAtStart: Bool,
    startPoint: UnitPoint,
    endPoint: UnitPoint
  ) -> LinearGradient {
    let rampLocation = fadeLength > 0 ? min(max(5 / fadeLength, 0), 1) : 1
    let stops: [Gradient.Stop]

    if transparentAtStart {
      stops = [
        Gradient.Stop(color: .clear, location: 0),
        Gradient.Stop(color: .black.opacity(0.4), location: rampLocation),
        Gradient.Stop(color: .black, location: 1),
      ]
    } else {
      stops = [
        Gradient.Stop(color: .black, location: 0),
        Gradient.Stop(color: .black.opacity(0.4), location: 1 - rampLocation),
        Gradient.Stop(color: .clear, location: 1),
      ]
    }

    return LinearGradient(
      stops: stops,
      startPoint: startPoint,
      endPoint: endPoint
    )
  }

  private func fadingEdge<G: View>(
    shows: Bool,
    @ViewBuilder gradient: () -> G
  ) -> some View {
    ZStack {
      gradient()
      Color.black.opacity(shows ? 0 : 1)
    }
  }
}

/// A scroll view that fades content at edges when more content exists to scroll.
///
/// SwiftUI equivalent of `ScrollableContainerNode` with `isGradientMaskingEnabled`.
/// Uses `.mask()` to fade content at edges where scrollable content overflows.
///
/// ```swift
/// EdgeEffectScrollView(.vertical, edges: [.bottom]) {
///   Text("Long content...")
/// }
/// ```
public struct EdgeEffectScrollView<Content: View>: View {

  private let axes: Axis.Set
  private let edges: Edge.Set
  private let radius: CGFloat
  private let maskPadding: EdgeInsets
  private let showsIndicators: Bool
  private let content: Content

  @State private var visibility = EdgeEffectMask.Visibility()

  /// Creates a scroll view that automatically applies an edge fade mask.
  ///
  /// - Parameters:
  ///   - axes: The scrollable axes.
  ///   - edges: The edges where fade ramps can appear.
  ///   - radius: The length of each fade ramp.
  ///   - maskPadding: Fully visible insets before the fade ramps begin.
  ///   - showsIndicators: A Boolean value that controls scroll indicator visibility.
  ///   - content: The scrollable content.
  public init(
    _ axes: Axis.Set = .vertical,
    edges: Edge.Set = [.top, .bottom],
    radius: CGFloat = 40,
    maskPadding: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
    showsIndicators: Bool = true,
    @ViewBuilder content: () -> Content
  ) {
    self.axes = axes
    self.edges = edges
    self.radius = radius
    self.maskPadding = maskPadding
    self.showsIndicators = showsIndicators
    self.content = content()
  }

  public var body: some View {
    ScrollView(axes, showsIndicators: showsIndicators) {
      content
    }
    .onScrollGeometryChange(for: EdgeEffectMask.Visibility.self) { geometry in
      EdgeEffectMask.Visibility(scrollGeometry: geometry, edges: edges)
    } action: { _, visibility in
      self.visibility = visibility
    }
    .mask {
      EdgeEffectMask(
        edges: edges,
        radius: radius,
        padding: maskPadding,
        visibility: visibility
      )
      .animation(.spring, value: visibility)
    }
  }
}

// MARK: - Preview

#Preview("Bottom fade") {
  EdgeEffectScrollView(.vertical, edges: [.bottom]) {
    VStack(spacing: 8) {
      ForEach(0..<30, id: \.self) { i in
        Text("Item \(i)")
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.blue.opacity(0.1))
          .clipShape(RoundedRectangle(cornerRadius: 8))
      }
    }
    .padding()
  }
  .frame(height: 400)
  .padding()
}

#Preview("Top + Bottom fade") {
  EdgeEffectScrollView(.vertical) {
    VStack(spacing: 8) {
      ForEach(0..<30, id: \.self) { i in
        Text("Item \(i)")
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.blue)
          .clipShape(RoundedRectangle(cornerRadius: 8))
      }
    }
  }
  .frame(height: 400)
  .padding()
}

#Preview("Short content - No fade") {
  EdgeEffectScrollView(.vertical) {
    VStack(spacing: 8) {
      ForEach(0..<3, id: \.self) { i in
        Text("Item \(i)")
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.blue)
          .clipShape(RoundedRectangle(cornerRadius: 8))
      }
    }
  }
  .frame(height: 400)
  .padding()
}

private struct ListEdgeEffectMaskPreview: View {

  @State private var visibility = EdgeEffectMask.Visibility()

  var body: some View {
    List(0..<40, id: \.self) { index in
      Text("List Item \(index)")
        .font(.body)
    }
   
    .mask {
      EdgeEffectMask(
        edges: [.top, .bottom],
        radius: 40,  
        visibility: .init(showsTop: true, showsBottom: true)
      )
    }
  }
}

#Preview("List mask") {
  ListEdgeEffectMaskPreview()
}
