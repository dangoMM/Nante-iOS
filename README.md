# Nante-iOS
文字起こしアプリのiOS画面
(文字起こしやユーザー登録のAPIは、別リポジトリにて開発しました。)

## 主要機能
### 環境構築
```
# 依存関係のインストール
Pod install
```

### 対応OS 
iOS 16以上

### 機能
- PodCastをURLから検索（RSSフィードの解析と、iTunesAPIを使用）
- 音声再生機能（単語をタップしたらそこに再生時間が戻る）
- バックエンドの文字起こしAPIを叩いて、表示する機能
- ログインやサインアップを行なって、認証する
