import SwiftUI

/// A capsule-style picker that scrolls to keep its selected segment in view.
///
/// Segments share the available width when their labels fit. Otherwise, they
/// retain their natural widths and scroll horizontally. Selection changes from
/// either a tap or the parent bring the selected segment toward the center,
/// clamped to the beginning and end of the content.
///
/// Items must have unique, stable identifiers. The parent owns the selection
/// and keeps it valid when removing items; dragging does not change selection.
public struct ScrollableSegmentedControl<Item: Identifiable, Label: View>: View {

  private let items: [Item]
  @Binding private var selection: Item.ID
  private let selectionColor: Color
  private let label: (Item) -> Label

  @Namespace private var selectionNamespace
  @State private var viewportWidth: CGFloat = 0
  @Environment(\.accessibilityReduceMotion) private var reducesMotion
  @Environment(\.layoutDirection) private var layoutDirection

  /// Creates a segmented picker with a label for each item.
  ///
  /// - Parameters:
  ///   - items: The ordered segments, identified independently of their labels.
  ///   - selection: The identifier of the selected item.
  ///   - selectionColor: The selected capsule's fill. Use a color that contrasts
  ///     with its white label.
  ///   - label: The content of each segment, usually a `Text` or `Label` view.
  public init(
    items: [Item],
    selection: Binding<Item.ID>,
    selectionColor: Color = .accentColor,
    @ViewBuilder label: @escaping (Item) -> Label
  ) {
    self.items = items
    self._selection = selection
    self.selectionColor = selectionColor
    self.label = label
  }

  public var body: some View {
    let itemIDs = items.map(\.id)

    ScrollViewReader { proxy in
      ScrollView(.horizontal) {
        SegmentRowLayout(
          minimumWidth: max(0, viewportWidth - 8),
          layoutDirection: layoutDirection
        ) {
          ForEach(items) { item in
            let isSelected = item.id == selection
            let foreground: Color = if isSelected { .white } else { .primary }
            let traits: AccessibilityTraits = if isSelected { .isSelected } else { [] }

            Button {
              selection = item.id
            } label: {
              label(item)
                .font(.body.weight(.semibold))
                .lineLimit(1)
                .fixedSize()
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(.vertical, 2)
                .foregroundStyle(foreground)
                .background {
                  if isSelected {
                    Capsule()
                      .fill(selectionColor)
                      .matchedGeometryEffect(id: "selection", in: selectionNamespace)
                  }
                }
                .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(traits)
            .id(item.id)
          }
        }
        .animation(selectionAnimation, value: selection)
        .padding(4)
        // Reapply the anchor after layout, including newly inserted segments
        // and text-size changes. This avoids scrolling to stale item frames.
        .onGeometryChange(for: CGSize.self) { geometry in
          geometry.size
        } action: { _ in
          proxy.scrollTo(selection, anchor: .center)
        }
      }
      .scrollIndicators(.hidden)
      .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
      .fixedSize(horizontal: false, vertical: true)
      .background(Color(uiColor: .secondarySystemFill), in: Capsule())
      .clipShape(Capsule())
      .onGeometryChange(for: CGFloat.self) { geometry in
        geometry.size.width
      } action: { width in
        viewportWidth = width
      }
      .onChange(of: selection) {
        withAnimation(selectionAnimation) {
          proxy.scrollTo(selection, anchor: .center)
        }
      }
      .onChange(of: itemIDs) {
        proxy.scrollTo(selection, anchor: .center)
      }
      .onChange(of: viewportWidth) {
        proxy.scrollTo(selection, anchor: .center)
      }
      .onChange(of: layoutDirection) {
        proxy.scrollTo(selection, anchor: .center)
      }
    }
  }

  private var selectionAnimation: Animation? {
    if reducesMotion { nil } else { .snappy(duration: 0.3) }
  }
}

/// Fits short labels into equal segments without compressing overflowing ones.
private struct SegmentRowLayout: Layout {

  let minimumWidth: CGFloat
  let layoutDirection: LayoutDirection

  func makeCache(subviews: Subviews) -> [CGSize] {
    subviews.map { $0.sizeThatFits(.unspecified) }
  }

  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout [CGSize]
  ) -> CGSize {
    CGSize(
      width: max(minimumWidth, cache.reduce(0) { $0 + $1.width }),
      height: cache.map(\.height).max() ?? 0
    )
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout [CGSize]
  ) {
    guard !subviews.isEmpty else { return }

    let equalWidth = bounds.width / CGFloat(subviews.count)
    let fitsEqualWidths = cache.allSatisfy { $0.width <= equalWidth }
    let remainingWidth = max(0, bounds.width - cache.reduce(0) { $0 + $1.width })
    let extraWidth = remainingWidth / CGFloat(subviews.count)
    var offset: CGFloat = 0

    for (subview, size) in zip(subviews, cache) {
      let width = if fitsEqualWidths { equalWidth } else { size.width + extraWidth }
      let x: CGFloat
      switch layoutDirection {
      case .leftToRight:
        x = bounds.minX + offset
      case .rightToLeft:
        x = bounds.maxX - offset - width
      @unknown default:
        x = bounds.minX + offset
      }

      subview.place(
        at: CGPoint(x: x, y: bounds.midY),
        anchor: .leading,
        proposal: ProposedViewSize(width: width, height: bounds.height)
      )
      offset += width
    }
  }
}

/// Exercises tapping, external selection, item insertion, and viewport changes.
private struct ScrollableSegmentedControlBook: View {

  @State private var twoItemSelection = "visitors"
  @State private var selection = "visitors"
  @State private var itemCount = 8
  @State private var usesNarrowWidth = false

  private let selectionColor = Color(red: 0, green: 0.48, blue: 0.54)

  var body: some View {
    let items = Array(Segment.samples.prefix(itemCount))
    let selectedItem = items.first { $0.id == selection } ?? items[0]
    let maximumWidth: CGFloat = if usesNarrowWidth { 240 } else { .infinity }

    ScrollView {
      VStack(alignment: .leading, spacing: 28) {
        VStack(alignment: .leading, spacing: 8) {
          Text("Scrollable segments")
            .font(.largeTitle.bold())
          Text("A filled selection that stays in view as the number of tabs grows.")
            .foregroundStyle(.secondary)
        }

        VStack(alignment: .leading, spacing: 12) {
          Text("Two tabs")
            .font(.headline)
          ScrollableSegmentedControl(
            items: Array(Segment.samples.prefix(2)),
            selection: $twoItemSelection,
            selectionColor: selectionColor
          ) { item in
            Text(item.title)
          }
          .accessibilityIdentifier("two-segments")
        }

        VStack(alignment: .leading, spacing: 16) {
          Text("Growing collection")
            .font(.headline)

          ScrollableSegmentedControl(
            items: items,
            selection: $selection,
            selectionColor: selectionColor
          ) { item in
            Text(item.title)
          }
          .frame(maxWidth: maximumWidth)
          .frame(maxWidth: .infinity)
          .accessibilityIdentifier("growing-segments")

          HStack {
            Text("Selected")
              .foregroundStyle(.secondary)
            Spacer()
            Text(selectedItem.title)
              .fontWeight(.semibold)
          }
          .accessibilityIdentifier("selected-segment")

          SegmentedControlActions(items: items, selection: $selection)

          Divider()

          Stepper("Segments: \(itemCount)", value: $itemCount, in: 2...Segment.samples.count)
            .accessibilityIdentifier("segment-count")
          Toggle("Narrow viewport", isOn: $usesNarrowWidth)
            .accessibilityIdentifier("narrow-viewport")
          Button("Add and select next tab", systemImage: "plus") {
            itemCount += 1
            selection = Segment.samples[itemCount - 1].id
          }
          .disabled(itemCount == Segment.samples.count)
          .accessibilityIdentifier("add-and-select")
        }
        .padding(20)
        .background(
          Color(uiColor: .secondarySystemGroupedBackground),
          in: RoundedRectangle(cornerRadius: 24)
        )
      }
      .padding(20)
    }
    .background(Color(uiColor: .systemGroupedBackground))
    .tint(selectionColor)
    .onChange(of: itemCount) {
      if !Segment.samples.prefix(itemCount).contains(where: { $0.id == selection }) {
        selection = Segment.samples[itemCount - 1].id
      }
    }
  }
}

/// Changes the binding without tapping a segment, including offscreen targets.
private struct SegmentedControlActions: View {

  let items: [Segment]
  @Binding var selection: String

  var body: some View {
    HStack {
      Button("First") { selection = items[0].id }
        .accessibilityIdentifier("select-first")
      Spacer()
      Button("Middle") { selection = items[items.count / 2].id }
        .accessibilityIdentifier("select-middle")
      Spacer()
      Button("Last") { selection = items[items.count - 1].id }
        .accessibilityIdentifier("select-last")
    }
    .buttonStyle(.bordered)
  }
}

/// Stable sample identities let labels and their positions change independently.
private struct Segment: Identifiable {

  let id: String
  let title: LocalizedStringResource

  static let samples: [Self] = [
    .init(id: "likes", title: "いいね！"),
    .init(id: "visitors", title: "足あと"),
    .init(id: "matches", title: "マッチング"),
    .init(id: "messages", title: "メッセージ"),
    .init(id: "favorites", title: "お気に入り"),
    .init(id: "recommended", title: "おすすめ"),
    .init(id: "online", title: "オンライン"),
    .init(id: "new", title: "新着"),
    .init(id: "nearby", title: "近くの人"),
    .init(id: "profile", title: "プロフィール"),
    .init(id: "notifications", title: "お知らせ"),
    .init(id: "all", title: "すべて"),
  ]
}

#Preview("Scrollable segmented control") {
  ScrollableSegmentedControlBook()
}

#Preview("Segmented control - Large text") {
  ScrollableSegmentedControlBook()
    .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("Segmented control - Right to left") {
  ScrollableSegmentedControlBook()
    .environment(\.layoutDirection, .rightToLeft)
}
