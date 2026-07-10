import SwiftUI
import UIKit

/// Demonstrates a SwiftUI screen that presents a private UIKit menu element.
private struct CustomViewMenuElementBook: View {

  @State private var status: CustomMenuStatus = .waiting

  var body: some View {
    NavigationStack {
      CustomViewMenuExplanation(status: status)
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle("Custom Menu")
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            CustomViewMenuButton(status: $status)
            .fixedSize()
          }
        }
    }
  }
}

/// Displays instructions and the most recent menu action.
private struct CustomViewMenuExplanation: View {

  let status: CustomMenuStatus

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Tap Edit")
        .font(.title2)

      Text("The entry button is a UIKit button hosted in SwiftUI. The first menu row is written in SwiftUI and hosted back in UIKit.")
        .font(.body)
        .foregroundStyle(.secondary)

      Text("Experiment only: UICustomViewMenuElement is private API.")
        .font(.footnote)
        .foregroundStyle(.orange)

      Text(status.title)
        .font(.headline)
        .accessibilityIdentifier("custom-menu-status")
    }
  }
}

/// The observable result of selecting an item from the demo menu.
private enum CustomMenuStatus: Equatable, Sendable {
  case waiting
  case customProfile
  case selectMessages
  case editPins
  case recentlyDeleted

  /// Localized text displayed by the SwiftUI screen.
  var title: LocalizedStringResource {
    switch self {
    case .waiting:
      "Waiting for an action"
    case .customProfile:
      "Custom profile row tapped"
    case .selectMessages:
      "Select Messages tapped"
    case .editPins:
      "Edit Pins tapped"
    case .recentlyDeleted:
      "Show Recently Deleted tapped"
    }
  }

  /// Stable diagnostic text written to the debug console.
  var debugDescription: String {
    switch self {
    case .waiting:
      "waiting"
    case .customProfile:
      "customProfile"
    case .selectMessages:
      "selectMessages"
    case .editPins:
      "editPins"
    case .recentlyDeleted:
      "recentlyDeleted"
    }
  }
}

/// Hosts the `UIButton` that owns the raw `UIMenu` inside SwiftUI.
///
/// A native SwiftUI `Menu` can't accept an arbitrary `UIMenuElement`, so the
/// UIKit button remains the narrow presentation boundary for this experiment.
private struct CustomViewMenuButton: UIViewRepresentable {

  @Binding private var status: CustomMenuStatus

  init(status: Binding<CustomMenuStatus>) {
    _status = status
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(status: $status)
  }

  func makeUIView(context: Context) -> UIButton {
    var configuration = UIButton.Configuration.plain()
    configuration.title = String(
      localized: "Edit",
      comment: "Button that opens the custom menu element experiment."
    )
    configuration.image = UIImage(systemName: "pencil")
    configuration.imagePadding = 5

    let button = UIButton(configuration: configuration)
    button.accessibilityIdentifier = "custom-menu-entry"
    button.showsMenuAsPrimaryAction = true
    button.menu = CustomViewMenuFactory.makeMenu { [weak coordinator = context.coordinator] status in
      coordinator?.report(status)
    }
    return button
  }

  func updateUIView(_ button: UIButton, context: Context) {
    context.coordinator.status = $status
  }

  /// Forwards UIKit menu callbacks into the current SwiftUI binding.
  @MainActor
  final class Coordinator {

    var status: Binding<CustomMenuStatus>

    init(status: Binding<CustomMenuStatus>) {
      self.status = status
    }

    func report(_ newStatus: CustomMenuStatus) {
      status.wrappedValue = newStatus
      print("[UICustomViewMenuElement] \(newStatus.debugDescription)")
    }
  }
}

/// Builds the UIKit menu while containing every private API reference.
@MainActor
private enum CustomViewMenuFactory {

  /// Creates the complete menu, including a visible fallback when the private
  /// class is absent from the running OS.
  static func makeMenu(
    onAction: @escaping @MainActor @Sendable (CustomMenuStatus) -> Void
  ) -> UIMenu {
    guard let customViewElement = makeCustomViewElement(onAction: onAction) else {
      let unavailableAction = UIAction(
        title: String(
          localized: "UICustomViewMenuElement is unavailable",
          comment: "Disabled menu item shown when the private UIKit class does not exist."
        ),
        attributes: .disabled
      ) { _ in }
      return UIMenu(children: [unavailableAction])
    }

    let selectMessages = UIAction(
      title: String(
        localized: "Select Messages",
        comment: "Menu action in the UICustomViewMenuElement experiment."
      ),
      image: UIImage(systemName: "checkmark.circle")
    ) { _ in
      onAction(.selectMessages)
    }
    let editPins = UIAction(
      title: String(
        localized: "Edit Pins",
        comment: "Menu action in the UICustomViewMenuElement experiment."
      ),
      image: UIImage(systemName: "pin")
    ) { _ in
      onAction(.editPins)
    }
    let recentlyDeleted = UIAction(
      title: String(
        localized: "Show Recently Deleted",
        comment: "Menu action in the UICustomViewMenuElement experiment."
      ),
      image: UIImage(systemName: "trash")
    ) { _ in
      onAction(.recentlyDeleted)
    }

    return UIMenu(children: [
      UIMenu(options: .displayInline, children: [customViewElement]),
      UIMenu(options: .displayInline, children: [selectMessages, editPins]),
      UIMenu(options: .displayInline, children: [recentlyDeleted]),
    ])
  }

  /// Creates a private custom-view element through the Objective-C runtime.
  private static func makeCustomViewElement(
    onAction: @escaping @MainActor @Sendable (CustomMenuStatus) -> Void
  ) -> UIMenuElement? {
    guard let elementClass = NSClassFromString("UICustomViewMenuElement") as? NSObject.Type else {
      return nil
    }

    let elementWithViewProvider = NSSelectorFromString("elementWithViewProvider:")
    let viewProvider: @convention(block) (UIMenuElement) -> UIView = { _ in
      UIHostingConfiguration {
        CustomMenuProfileRow()
      }
      .margins(.all, 0)
      .makeContentView()
    }

    guard
      let result = elementClass.perform(elementWithViewProvider, with: viewProvider),
      let customViewElement = result.takeUnretainedValue() as? UIMenuElement
    else {
      return nil
    }

    let setPrimaryActionHandler = NSSelectorFromString("setPrimaryActionHandler:")
    let primaryActionHandler: @convention(block) (UIMenuElement) -> Void = { _ in
      onAction(.customProfile)
    }
    _ = customViewElement.perform(setPrimaryActionHandler, with: primaryActionHandler)

    return customViewElement
  }
}

/// SwiftUI content rendered inside the private UIKit menu element.
private struct CustomMenuProfileRow: View {

  var body: some View {
    HStack(spacing: 10) {
      Image(systemName: "person.crop.circle.fill")
        .font(.largeTitle)
        .foregroundStyle(.teal)

      VStack(alignment: .leading, spacing: 1) {
        Text("Seb Vidal")
          .font(.headline)

        Text("Name & Photo")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }

      Spacer(minLength: 0)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 10)
    .fixedSize(horizontal: false, vertical: true)
    .accessibilityElement(children: .combine)
  }
}

#Preview("UICustomViewMenuElement") {
  CustomViewMenuElementBook()
}
