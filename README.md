# 天気予報アプリ - WeatherReport

OpenWeatherMapの「5 Day / 3 Hour Forecast」APIを利用して、各地の天気予報を確認できるiOSアプリケーションです。

## 概要

### 主要機能
- 5日間の3時間単位天気予報
- 主要6地域対応（現在地含む）
- オフラインキャッシュ機能

### 画面構成と仕様
- ホーム画面
    - 地域を選択
        - 東京、大阪、兵庫、大分、北海道、現在地を選択する
        - 選択後、天気画面へ遷移
- 天気画面
    - ホーム画面で選択された地域の5日間（最大40件）の3時間ごとの天気予報データを表示
    - 天気アイコン、天気コメント、最高気温、最低気温、降水確率を表示
    - 天気予報データをSwiftDataでキャッシュの永続化し、同⽇同地域へのAPIリクエストを⾏う場合は代わりにキャッシュを表⽰する。（キャッシュの有効期限は同⽇とし、⽇付が変わった後に画⾯を表⽰した場合は、APIリクエストを実⾏する）

### スクリーンショット

- ホーム画面  
    <img src="https://github.com/user-attachments/assets/3e1b9b85-d4d3-4319-8e3e-e1f86cfa7ebe" width=220px>

- 天気画面  
    <img src="https://github.com/user-attachments/assets/b2483840-ed15-4efe-bad4-a8794d8cff62" width=220px>

---

## 開発環境の構築方法

- **言語:** Swift 5
- **IDE:** Xcode 16.3
- **対応OS:** iOS 17.0以降（SwiftDataを活用）

1. **リポジトリをクローン**
```bash
$ git clone https://github.com/sora5042/WeatherReport.git
```

2. **必要なライブラリをインストール**
- Swift Package Managerを使用してライブラリをインストールします。

## 利用したライブラリ

- [**KeychainAccess**](https://github.com/kishikawakatsumi/KeychainAccess)

    **理由**
    - Keychainの操作を簡単かつ直感的に実装することができます。
---

## アーキテクチャパターン
- MVVM

    **理由**
    - 責務の分離
        - UIロジック（View）とビジネスロジック（Model, ViewModel）を分離することで、コードの可読性と保守性を向上させます。
    - SwiftUIとの親和性
        - SwiftUIはデータバインディングを活用した宣言的なUIフレームワークであり、MVVMと相性が良いです。
    - Swift Concurrencyとの相性
        - Swift Concurrencyは単方向データフロー（Single Source of Truth）の設計思想と調和し、状態管理やタスク実行を安全かつ効率的に行えます。また、async/awaitは非同期処理をシンプルに記述できるため、APIとの通信処理などを効率的に実装できます。

## ツール

- SwiftLint

    **理由**
    - Swiftコードのスタイルや規約を自動的にチェックし、違反箇所を警告してくれます。
    - 統一されたコーディングスタイルを維持でき、コードレビュー時のフォーマットに関する指摘を削減します。
    - `.swiftlint.yml`ファイルでルールを柔軟にカスタマイズ可能で、プロジェクトごとに最適な設定が行えます

- SwiftFormat

     **理由**
    - SwiftFormatは、Swiftコードのフォーマットを自動化するツールで、コードの可読性と一貫性を向上させます。
    - フォーマットルールを事前に設定することで、チーム全体で統一されたコードスタイルを維持できます。

---

## 実装上の工夫点

1. **非同期処理**
- Swift Concurrencyの`async/await`を活用して非同期処理を簡潔に記述し、エラー発生時には適切な通知を表示するよう実装しました。
2. **シンプルな実装**
- 実装内容をできるだけシンプルにし、可読性向上や変更容易性を意識しました。
3. **レスポンシブデザイン**
- SwiftUIのレイアウト特性を活かし、多様な画面サイズに対応するUI設計を行いました。

## 今後の課題

- ユニットテストカバレッジの向上。（Swift Testtingなど）
- TCAやVIPERなど他のアーキテクチャについての知識習得
    - MVVM以外のアーキテクチャパターンについても研究し、適切な場面で採用できるようにしたいです。
- Swift6に移行について。
- WidgetKitによるホーム画面ウィジェットを追加してみたいです。