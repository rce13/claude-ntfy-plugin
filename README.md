# claude-ntfy

Claude Codeが確認待ちになったとき、スマホにプッシュ通知を送るプラグイン。

> **詳細ガイド / Detailed Guide**: [日本語](docs/guide-ja.md) | [English](docs/guide-en.md)

## 機能

- **5分遅延通知**: 即時ではなく、5分間反応がない場合のみ通知（スパム防止）
- **Remote Control連携**: 通知タップでそのセッションに直接アクセス
- **自動キャンセル**: 5分以内にユーザーが入力すると通知は送られない

## 必要なもの

- Claude Code v2.1.51+
- [ntfy](https://ntfy.sh) アプリ（Android / iOS）
- `jq` コマンド（ほとんどの環境にプリインストール済み）
- `curl` コマンド

## インストール

### 1. プラグインを取得

```bash
git clone https://github.com/rce13/claude-ntfy-plugin.git ~/.claude/plugins/claude-ntfy
```

または一時的に試す場合:

```bash
git clone https://github.com/rce13/claude-ntfy-plugin.git
claude --plugin-dir ./claude-ntfy-plugin
```

### 2. ntfy.shのセットアップ

Claude Code内で `/setup-ntfy` を実行すると、対話的にセットアップできます。

手動の場合:

```bash
mkdir -p ~/.claude-ntfy
cat > ~/.claude-ntfy/config << 'EOF'
CLAUDE_NTFY_TOPIC="your-unique-topic-name"
CLAUDE_NTFY_DELAY=300
CLAUDE_NTFY_SERVER="ntfy.sh"
EOF
```

> **注意**: `CLAUDE_NTFY_TOPIC` には推測されにくいユニークな名前を使ってください（例: `myname-claude-abc123`）。ntfy.shの公開トピックは誰でもアクセスできます。

### 3. スマホ側

1. ntfyアプリをインストール（[Android](https://play.google.com/store/apps/details?id=io.heckel.ntfy) / [iOS](https://apps.apple.com/app/ntfy/id1625396347)）
2. アプリを開き、設定したトピック名を購読
3. （推奨）Claude Code Remote Controlも有効化 → 通知タップでセッションを直接操作

### 4. Remote Control自動起動（推奨）

Claude Code内で `/config` → 「Enable Remote Control for all sessions」を有効化。

通知にRemote ControlのセッションURLが自動的に含まれ、タップするだけでそのセッションにアクセスできます。

## 動作の流れ

```
Claude Code承認待ち
  ↓
Notification hook発火 → マーカーファイル作成 + 5分タイマー開始
  ↓
[5分以内にユーザー入力] → マーカー削除 → 通知なし
[5分間放置]            → ntfy.sh通知送信 → スマホに届く
                         ↓
                       通知タップ → Remote Controlでセッション操作
```

## 設定項目

| 変数 | 説明 | デフォルト |
|------|------|-----------|
| `CLAUDE_NTFY_TOPIC` | ntfy.shのトピック名（必須） | なし |
| `CLAUDE_NTFY_DELAY` | 通知までの待機秒数 | `300` (5分) |
| `CLAUDE_NTFY_SERVER` | ntfyサーバーURL（セルフホスト用） | `ntfy.sh` |

## セルフホストntfyサーバー

プライバシーが気になる場合は、[ntfyをセルフホスト](https://docs.ntfy.sh/install/)して `CLAUDE_NTFY_SERVER` に自分のサーバーURLを設定できます。

## ライセンス

MIT
