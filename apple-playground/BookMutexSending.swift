import Synchronization


private func run() {
  
  let m = Mutex("")
  
  m.withLock { value in
    
  }
  
  let a = MyMutex("")
  
  a.withLock { a in
    
  }
}
import os

/// 排他制御によって共有可変状態を保護する同期プリミティブ。
///
/// `@unchecked Sendable` により、この型は `Value` が `Sendable` でなくても
/// isolation domain 間で共有できます。コンパイラはロックによる排他制御を
/// 検証できないため、次の不変条件をこの実装が保証します。
///
/// - `storage.value` へのアクセスは、初期化時を除いて必ずロック中に行う。
/// - `storage` を外部へ公開せず、ロックを経由しないアクセスを許可しない。
///
/// - Important: `@unchecked Sendable` 自体は `Value` を移動させません。
///   初期値やクロージャの入出力を isolation domain 間で受け渡す契約は、
///   `sending` によって表現します。
nonisolated struct MyMutex<Value>: @unchecked Sendable {

  private let lock = OSAllocatedUnfairLock()
  private let storage: Storage

  /// 指定された初期値を保護する mutex を生成します。
  ///
  /// `consuming sending` は、初期値の所有権と isolation region を
  /// mutex の内部へ移します。これにより、non-`Sendable` な値も、
  /// 呼び出し元に競合するアクセスを残さずに保護対象にできます。
  init(_ value: consuming sending Value) {
    storage = Storage(value)
  }

  /// ロックを取得し、保護された値への排他的アクセスを提供します。
  ///
  /// `inout sending Value` は、保護値への排他的な変更アクセスに加えて、
  /// クロージャとの境界で isolation region を受け渡すことを表します。
  /// `sending Result` は、コンパイラが安全に移動できると確認した結果を、
  /// クロージャの外側へ返せることを表します。
  ///
  /// - Important: `sending` は、mutex 内にも残っている non-`Sendable` な
  ///   参照を無条件に外へ漏らしてよい、という指定ではありません。
  ///   ロックは実行時の排他制御を、`sending` はコンパイル時の
  ///   isolation transfer をそれぞれ担当します。
  borrowing func withLock<Result: ~Copyable, E: Error>(
    perform: (inout sending Value) throws(E) -> sending Result
  ) throws(E) -> sending Result {
    lock.lock()
    defer {
      lock.unlock()
    }

    // ロックで実行時の排他性を確立した状態で、保護値の isolation region を
    // クロージャへ渡し、移動可能な結果を呼び出し元へ返します。
    return try perform(&storage.value)
  }

  /// 保護対象に安定した参照を与える内部ストレージ。
  private final class Storage {

    var value: Value

    init(_ value: consuming Value) {
      self.value = value
    }
  }
}
