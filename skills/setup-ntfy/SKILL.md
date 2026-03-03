---
name: setup-ntfy
description: Set up ntfy.sh push notifications for Claude Code
user-invocable: true
disable-model-invocation: true
---

# setup-ntfy

Claude Codeの確認待ち時にスマホへプッシュ通知を送るntfy.sh連携をセットアップします。

## セットアップ手順

1. ユーザーにntfy.shのトピック名を聞く（推測されにくいユニークな名前を推奨、例: `myname-claude-abc123`）
2. `~/.claude-ntfy/config` に設定を書き込む:

```bash
mkdir -p ~/.claude-ntfy
cat > ~/.claude-ntfy/config << 'CONF'
CLAUDE_NTFY_TOPIC="<ユーザーが指定したトピック名>"
CLAUDE_NTFY_DELAY=300
CLAUDE_NTFY_SERVER="ntfy.sh"
CONF
```

3. テスト通知を送信して動作確認:

```bash
curl -s -H "Title: Claude Code" -d "Setup complete - notifications working!" "ntfy.sh/<トピック名>"
```

4. Remote Control自動起動が未設定なら、`~/.claude.json` に `"remoteControlAtStartup": true` を追加

5. スマホ側の手順を案内:
   - ntfyアプリをインストール（Play Store / App Store）
   - アプリで指定したトピック名を購読

## 設定項目

| 変数 | 説明 | デフォルト |
|------|------|-----------|
| CLAUDE_NTFY_TOPIC | ntfy.shのトピック名（必須） | なし |
| CLAUDE_NTFY_DELAY | 通知までの待機秒数 | 300 (5分) |
| CLAUDE_NTFY_SERVER | ntfyサーバーURL | ntfy.sh |
