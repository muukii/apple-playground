import Foundation
import os
import Playgrounds

/// An object whose lifetime makes the retained capture visible.
private final class AsyncStreamReproModel: @unchecked Sendable {

  let label: String
  let value = 42

  init(label: String) {
    self.label = label
  }

  deinit {
    print("[\(label)] Model.deinit")
  }
}

/// Holds a weak reference so the playground can inspect object lifetime.
private final class AsyncStreamReproWeakBox<Value: AnyObject>: @unchecked Sendable {

  weak var value: Value?

  init(_ value: Value) {
    self.value = value
  }
}

/// Mimics a StateGraph node retaining a tracking registration.
private nonisolated final class AsyncStreamReproRegistration: @unchecked Sendable {

  private let callback = OSAllocatedUnfairLock<(@Sendable () -> Void)?>(
    uncheckedState: nil
  )

  func install(_ body: @escaping @Sendable () -> Void) {
    callback.withLock { $0 = body }
  }

  func fire() {
    callback.withLock { $0 }?()
  }

  func cancel() {
    callback.withLock { $0 = nil }
  }
}

/// Keeps the registration alive after the consumer exits, like a Stored node does.
private struct AsyncStreamReproScenario: Sendable {

  let registration: AsyncStreamReproRegistration
  let weakModel: AsyncStreamReproWeakBox<AsyncStreamReproModel>
}

private func consumeOne(
  label: String,
  cleanupOnTermination: Bool
) async -> AsyncStreamReproScenario {

  let registration = AsyncStreamReproRegistration()
  let model = AsyncStreamReproModel(label: label)
  let weakModel = AsyncStreamReproWeakBox(model)

  let stream = AsyncStream<Int> { continuation in
    continuation.onTermination = { termination in
      print("[\(label)] onTermination:", termination)

      if cleanupOnTermination {
        registration.cancel()
      }
    }

    // Registration -> callback -> model + Continuation
    registration.install {
      continuation.yield(model.value)
    }
    registration.fire()
  }

  for await value in stream {
    print("[\(label)] received:", value)
    break
  }

  print("[\(label)] left for-await")

  return .init(
    registration: registration,
    weakModel: weakModel
  )
}

#Playground("AsyncStream termination retention") {

  let broken = await consumeOne(
    label: "broken",
    cleanupOnTermination: false
  )

  await Task.yield()
  print(
    "[broken] alive after break:",
    broken.weakModel.value != nil
  )

  broken.registration.cancel()
  print(
    "[broken] alive after manual cancel:",
    broken.weakModel.value != nil
  )

  let fixed = await consumeOne(
    label: "fixed",
    cleanupOnTermination: true
  )

  await Task.yield()
  print(
    "[fixed] alive after break:",
    fixed.weakModel.value != nil
  )
}
