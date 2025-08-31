# 📈 Crippo  
- **アプリ名**: Crippo  
- **開発期間**: 2025年4月 
- **開発形態**: 個人開発  

## ✅ 主な機能  
**1. トレンド表示**  
人気コイン TOP15、人気NFT TOP7 をランキング形式で表示

**2. コイン検索**  
名前・シンボルで検索し、詳細画面へ遷移可能

**3. お気に入り管理**  
コインのお気に入り登録/解除、および専用画面で一覧表示  

## 💻 技術スタック  
- **言語**: `Swift`  
- **フレームワーク**: `SwiftUI`  
- **アーキテクチャ**: `MVVM (Action/Output パターン)`  
- **非同期処理**: `Combine`, `Swift Concurrency (async/await)`  
- **ネットワーク**: `URLSession`  

## 🔎 工夫した点  
### 1. SwiftUI 状態管理とレンダリング最適化  
- `@StateObject`でViewModelのライフサイクルを固定し、下位ビューには`@ObservedObject`で共有  
- 画面専用のView State(Output)のみを公開し、不要な再レンダリングを抑制  
- カスタム`LazyView`を導入し、TabViewの非表示タブ初期化を遅延させ初回描画を軽量化  

### 2. MVVM + Action/Output パターン  
- `ViewModelType`プロトコルでInput/Action/Output構造を統一  
- ViewはAction送信とOutput購読のみを担当し、単方向データフローを維持  

### 3. Combine + Swift Concurrency  
- ユーザー入力や画面イベントをSubjectベースで管理 (Combine)  
- ネットワーク呼び出しは`async/await`で実装し、依存関係のないものは`async let`で並列実行  
- ViewModelでCombineイベントとConcurrency処理を結合し、Outputに反映  

## 📷 画面  
| トレンド | 検索 | 詳細 | お気に入り |
|:--:|:--:|:--:|:--:|
| <img alt="Simulator Screenshot - iPhone 14 Pro - 2025-08-29 at 18 33 22" src="https://github.com/user-attachments/assets/4168b029-36b0-4d54-b7ad-a0a1e18e7aa5" />　| <img alt="Simulator Screenshot - iPhone 14 Pro - 2025-08-29 at 18 33 36" src="https://github.com/user-attachments/assets/666445c4-da86-4999-9d9a-a69f2f891f0a" />　| <img alt="Simulator Screenshot - iPhone 14 Pro - 2025-08-29 at 18 53 18" src="https://github.com/user-attachments/assets/17289e4f-6ef2-4e97-9944-6f887944d26e" />　| <img alt="Simulator Screenshot - iPhone 14 Pro - 2025-08-29 at 18 33 42" src="https://github.com/user-attachments/assets/9222284e-5cd5-4c34-8955-ed67f689c13b" /> |
