# GlassEffectTransition.matchedGeometry Example

## 設計判断

- 通常の `matchedGeometryEffect` と混同しにくいよう、常に残る円形のガラスボタンの近くへ、別 ID のツールパレットを追加・削除する例にする。
- `GlassEffectContainer` の `spacing` より近い位置にパレットを配置し、`matchedGeometry` が近傍の既存ガラス形状を遷移元として選べる構成にする。
- 既存の Storybook 構成に合わせ、アプリの起点は変更せず `#Preview` から実行できる `Book` ファイルとして追加する。

## 逸脱点

- なし。

## トレードオフ

- Apple の最小例をそのまま複製する案より、円形ボタンから横長パレットが生える例のほうが形状補間を確認しやすいため、実用的なツールパレットを選んだ。
- `GlassEffectTransition` は iOS 26 以降のため、プロジェクト全体の deployment target は変更せず、サンプル型に availability を付ける。

## 検証

- Apple Developer Documentation とローカルの iOS 27 SDK interface で、`GlassEffectContainer`、`glassEffectID(_:in:)`、`glassEffectTransition(.matchedGeometry)` の組み合わせと iOS 26 availability を確認済み。
- Xcode 27 Beta 2 の `apple-playground` scheme でビルド成功。追加ファイル由来の warning / error はなし。
- iPhone 17 Pro（iOS 27）Simulator への install と app launch は成功。
- 画面キャプチャとタップ操作は、元の依頼に端末操作の明示承認がないとして実行環境に拒否されたため未実施。迂回や再試行はしていない。
- 新規ファイルを含む whitespace check で問題なし。

## 未解決の確認事項

- 実際の morph の画面確認が必要な場合は、Simulator の画面取得・操作を明示的に依頼してもらう必要がある。

# UICustomViewMenuElement Gist Trial

## 設計判断

- Gist の private runtime lookup を独立した Storybook Book に隔離し、既存の起動画面や他のサンプルを変更しない。
- private class が現行 OS から削除されている可能性を観察できるよう、force cast ではなく画面上へ unavailable 状態を出す。
- カスタム行と通常の `UIAction` のどちらを押したか、画面と console の両方で確認できるようにする。

## 逸脱点

- Gist の `.avatar` はこのプロジェクトに存在しないため、SF Symbol の `person.crop.circle.fill` へ置き換える。
- Gist の force cast は private API の有無を調べるサンプルとして不要なクラッシュを招くため、安全な runtime lookup に置き換える。

## トレードオフ

- SwiftUI 風の API へ一般化すると private API を通常利用する設計に見えるため、UIKit の実験用 ViewController 内に実装を閉じ込める。
- App Store で利用できる代替実装は同じ menu surface を再現できないため、このサンプルには混在させない。

## 検証

- Apple Developer Documentation で、public API としては `UIBarButtonItem.menu` による menu 表示が提供される一方、`UICustomViewMenuElement` に対応する公開 symbol がないことを確認した。
- Xcode の `apple-playground` scheme を iPhone 17 Pro（iOS 27.0）Simulator 向けにビルド成功。追加ファイル由来の warning / error はなし。既存の `BookPreferredLanguages.swift` に unused-result warning が残っている。
- Storybook から `UICustomViewMenuElement` を開き、Edit menu 内に `Seb Vidal` / `Name & Photo` を含む custom cell が表示されることを UI hierarchy と画面で確認した。
- custom cell を hierarchy 由来の座標でタップすると menu が閉じ、`custom-menu-status` が `Custom profile row tapped` に更新された。process は同一 PID のまま Running で crash なし。
- 新規ファイルを含む whitespace check で問題なし。

## 未解決の確認事項

- なし。

## 最終まとめ

- 変更ファイル: `apple-playground/BookCustomViewMenuElement.swift`、`implementation-notes.md`。
- Gist の挙動は iOS 27.0 Simulator でも再現した。
- private API のため、App Store 提出対象へ組み込める実装ではない。

## SwiftUI Hosting Refactor

### 設計判断

- Book の画面と custom menu row を SwiftUI で実装し、UIKit は raw `UIMenu` を所有する `UIButton` と private element factory だけに限定する。
- 入口は `UIViewRepresentable<UIButton>` として SwiftUI toolbar に配置する。純粋な SwiftUI `Menu` は raw `UIMenuElement` を受け取れないため使用しない。
- custom row は `UIHostingConfiguration.makeContentView()` で `UIView` 化し、private view-provider block へ返す。
- menu action は coordinator と KeyPath-based `Binding` を経由して SwiftUI の `@State` へ戻す。

### 逸脱点

- なし。

### トレードオフ

- `UIHostingController` は view-controller containment と lifetime 管理が必要になるため、view provider が `UIView` のみを要求するこの用途では `UIHostingConfiguration` を選んだ。
- entry button の見た目と配置は SwiftUI から管理できるが、実体は raw `UIMenu` を提示できる UIKit `UIButton` のままになる。
- Storybook 固有の Info button と entry button が並ぶため、navigation title は省略表示を避けられる `Custom Menu` に短縮した。

### 検証

- Xcode MCP は `Transport closed` で利用できなかったため、同じ Xcode 27 Beta 2 toolchain の `xcodebuild` へ切り替えた。iPhone 17 Pro / iOS 27.0 destination 向けビルドは成功。
- 追加ファイル由来の warning / error はなし。既存の `BookPreferredLanguages.swift` に unused-result warning が残っている。
- 既存の iPhone 17 Pro Simulator は Device Interaction / Mobile MCP の hierarchy RPC が timeout したため、ユーザーの既存状態を止めず、別の iPhone 17 / iOS 27.0 Simulator を boot して検証した。
- SwiftUI toolbar 内で UIKit entry button が `custom-menu-entry` として取得でき、タップで menu が表示された。
- menu 内の SwiftUI row は UI hierarchy で `Seb Vidal, Name & Photo` として取得でき、画面上も欠け・重なりなし。
- hierarchy 由来の row 座標をタップすると menu が閉じ、KeyPath-based `Binding` 経由で `custom-menu-status` が `Custom profile row tapped` に更新された。
- タップ後も `UIKitApplication:app.muukii.apple-playground` は PID 77649、exit status 0 で実行継続し、crash なし。
- navigation title を `Custom Menu` に短縮後、Storybook の Back / Info / Edit と並んでも省略されないことを UI hierarchy と画面で再確認した。
- 検証用 screenshot: `/tmp/swiftui-menu-entry.png`、`/tmp/swiftui-menu-open.png`、`/tmp/swiftui-menu-tapped.png`、`/tmp/swiftui-menu-final.png`、`/tmp/swiftui-menu-open-final.png`。

### 未解決の確認事項

- なし。

### 最終まとめ

- Book 本体と custom menu row は SwiftUI、raw `UIMenu` を提示する entry のみ `UIViewRepresentable<UIButton>`、private API lookup は factory に隔離した。
- SwiftUI / UIKit / SwiftUI の双方向 hosting と action callback の実動作を iOS 27.0 Simulator で確認済み。
