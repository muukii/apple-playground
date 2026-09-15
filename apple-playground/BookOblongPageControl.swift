import SwiftUI

/// A page indicator that displays equally sized, horizontal capsules.
///
/// Up to 50 pages fit across the available width. Additional pages keep the
/// same capsule width and scroll to keep the current page visible, centering
/// it whenever the content bounds allow.
///
/// The parent owns the current page. This view only displays that value; it
/// does not change the selected page when the indicator is dragged.
public struct OblongPageControl: View {

  private let numberOfPages: Int
  private let currentPage: Int
  private let hidesForSinglePage: Bool
  private let height: CGFloat

  @Environment(\.accessibilityReduceMotion) private var reducesMotion

  /// Creates an oblong page indicator.
  ///
  /// - Parameters:
  ///   - numberOfPages: The total page count. Nonpositive counts display nothing.
  ///   - currentPage: The zero-based selected page. Out-of-range values are
  ///     clamped for display without modifying the parent's value.
  ///   - hidesForSinglePage: Whether to omit the indicator for a single page.
  ///   - height: The capsule height, in points. The default is 2.
  ///
  /// Changing the page count preserves the supplied selection. Reset the
  /// parent's current page to zero when replacing a gallery if needed.
  public init(
    numberOfPages: Int,
    currentPage: Int = 0,
    hidesForSinglePage: Bool = false,
    height: CGFloat = 2
  ) {
    self.numberOfPages = numberOfPages
    self.currentPage = currentPage
    self.hidesForSinglePage = hidesForSinglePage
    self.height = max(height, 0)
  }

  public var body: some View {
    if numberOfPages > 0 && !(hidesForSinglePage && numberOfPages == 1) {
      GeometryReader { geometry in
        let visiblePageCount = min(numberOfPages, 50)
        // The UIKit viewport extends 40pt past either side, with 48pt content
        // insets. This leaves an effective 8pt inset inside the proposed width.
        let viewportWidth = geometry.size.width + 80
        let capsuleWidth = max(
          1,
          (viewportWidth - 96 - 2 * CGFloat(visiblePageCount - 1))
            / CGFloat(visiblePageCount)
        )

        ScrollViewReader { proxy in
          ScrollView(.horizontal) {
            LazyHStack(spacing: 2) {
              // Page positions are the identity of these presentation-only marks.
              ForEach(0..<numberOfPages, id: \.self) { page in
                let opacity = if page == selectedPage { 0.9 } else { 0.5 }
                Capsule()
                  .fill(.white.opacity(opacity))
                  .frame(width: capsuleWidth, height: height)
                  .id(page)
              }
            }
            .padding(.horizontal, 48)
          }
          .scrollIndicators(.hidden)
          .scrollBounceBehavior(.basedOnSize)
          .onChange(of: geometry.size, initial: true) {
            proxy.scrollTo(selectedPage, anchor: .center)
          }
          .onChange(of: numberOfPages) {
            proxy.scrollTo(selectedPage, anchor: .center)
          }
          .onChange(of: selectedPage) {
            withAnimation(selectionAnimation) {
              proxy.scrollTo(selectedPage, anchor: .center)
            }
          }
        }
        .frame(width: viewportWidth, height: height)
        .frame(width: geometry.size.width, height: height)
        // Preserve the original viewport's position relative to its owner.
        .offset(y: 2)
      }
      .frame(height: height)
      .accessibilityElement(children: .ignore)
      .accessibilityLabel("Pages")
      .accessibilityValue("Page \(selectedPage + 1) of \(numberOfPages)")
    }
  }

  private var selectedPage: Int {
    guard numberOfPages > 0 else { return 0 }
    return min(max(currentPage, 0), numberOfPages - 1)
  }

  private var selectionAnimation: Animation? {
    if reducesMotion { nil } else { .snappy(duration: 0.25) }
  }
}

/// An interactive gallery for checking selection, resizing, and page-count changes.
private struct OblongPageControlBook: View {

  @State private var numberOfPages = 5
  @State private var currentPage = 0
  @State private var hidesForSinglePage = false
  @State private var usesNarrowWidth = false

  var body: some View {
    let indicatorWidth: CGFloat = if usesNarrowWidth { 160 } else { 280 }
    ScrollView {
      VStack(spacing: 28) {
        VStack(spacing: 20) {
          Text("Page \(currentPage + 1) of \(numberOfPages)")
            .font(.headline.monospacedDigit())

          OblongPageControl(
            numberOfPages: numberOfPages,
            currentPage: currentPage,
            hidesForSinglePage: hidesForSinglePage,
            height: 6
          )
          .frame(width: indicatorWidth)

          HStack {
            Button("Previous", systemImage: "chevron.left") {
              currentPage = max(currentPage - 1, 0)
            }
            .disabled(currentPage <= 0)

            Spacer()

            Button("Next", systemImage: "chevron.right") {
              currentPage = min(currentPage + 1, numberOfPages - 1)
            }
            .disabled(currentPage >= numberOfPages - 1)
          }

          HStack {
            Button("First") { currentPage = 0 }
            Spacer()
            Button("Middle") { currentPage = numberOfPages / 2 }
            Spacer()
            Button("Last") { currentPage = numberOfPages - 1 }
          }
        }
        .padding(24)
        .background(.black.opacity(0.3), in: RoundedRectangle(cornerRadius: 20))

        VStack(spacing: 16) {
          Picker("Pages", selection: $numberOfPages) {
            ForEach([1, 5, 50, 51, 100], id: \.self) { count in
              Text(count, format: .number).tag(count)
            }
          }
          .pickerStyle(.segmented)

          Toggle("Hide single page", isOn: $hidesForSinglePage)
          Toggle("Narrow width", isOn: $usesNarrowWidth)
        }
      }
      .padding(24)
    }
    .background(Color(white: 0.18))
    .preferredColorScheme(.dark)
    .onChange(of: numberOfPages) {
      currentPage = min(currentPage, numberOfPages - 1)
    }
  }
}

/// A labeled sample that makes an empty or hidden indicator's bounds visible.
private struct OblongPageControlSample: View {

  let title: String
  let numberOfPages: Int
  var currentPage = 0
  var hidesForSinglePage = false

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.caption)

      OblongPageControl(
        numberOfPages: numberOfPages,
        currentPage: currentPage,
        hidesForSinglePage: hidesForSinglePage,
        height: 6
      )
      .frame(width: 240, height: 10)
      .background(.black.opacity(0.25))
    }
  }
}

#Preview("Oblong page control") {
  OblongPageControlBook()
}

#Preview("Page counts") {
  VStack(spacing: 24) {
    ForEach([1, 2, 3, 5, 10, 50, 51, 100], id: \.self) { count in
      OblongPageControlSample(
        title: "\(count) pages",
        numberOfPages: count,
        currentPage: count / 2
      )
    }
  }
  .padding(48)
  .background(Color(white: 0.18))
  .preferredColorScheme(.dark)
}

#Preview("Boundaries") {
  VStack(spacing: 24) {
    OblongPageControlSample(title: "Zero pages", numberOfPages: 0)
    OblongPageControlSample(title: "Negative count", numberOfPages: -1)
    OblongPageControlSample(
      title: "Hidden single page", numberOfPages: 1, hidesForSinglePage: true
    )
    OblongPageControlSample(title: "Negative selection", numberOfPages: 5, currentPage: -1)
    OblongPageControlSample(title: "Selection past end", numberOfPages: 5, currentPage: 10)
    OblongPageControlSample(title: "Overflow: first", numberOfPages: 100, currentPage: 0)
    OblongPageControlSample(title: "Overflow: middle", numberOfPages: 100, currentPage: 50)
    OblongPageControlSample(title: "Overflow: last", numberOfPages: 100, currentPage: 99)
  }
  .padding(48)
  .background(Color(white: 0.18))
  .preferredColorScheme(.dark)
}
