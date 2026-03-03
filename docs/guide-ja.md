# claude-ntfy 導入ガイド

Claude Codeで長時間タスクを実行中、確認待ちになったことに気づかず放置してしまった経験はありませんか？

**claude-ntfy** は、Claude Codeが確認待ちになったときにスマホへプッシュ通知を送るプラグインです。ntfy.shを利用しており、アカウント登録不要・無料で使えます。

## こんな人向け

- Claude Codeでタスクを走らせて、別の作業をしている人
- 承認待ちに気づかず時間を無駄にしたくない人
- スマホからClaude Codeを操作したい人（Remote Control連携）

## 仕組み

```
Claude Codeが承認待ちになる
  ↓
Notification hook発火
  ↓
マーカーファイル作成 + 5分タイマー開始
  ↓
┌─ 5分以内にユーザーが入力 → マーカー削除 → 通知なし
└─ 5分間放置 → ntfy.sh通知送信 → スマホに届く
                                    ↓
                                  通知タップ → Remote Controlでセッション操作
```

- **5分遅延**: すぐに通知せず、5分間反応がなければ通知を送信（通知スパム防止）
- **自動キャンセル**: 5分以内にユーザーが入力するとタイマーは自動キャンセル
- **Remote Control連携**: 通知にセッションURLを含めて、タップで直接操作可能

---

## 必要なもの

| 項目 | 要件 |
|------|------|
| Claude Code | v2.1.51 以降 |
| ntfyアプリ | Android または iOS |
| jq | ほとんどの Linux/macOS にプリインストール済み |
| curl | ほとんどの環境にプリインストール済み |

---

## ステップ 1: プラグインのインストール

### 方法A: 永続インストール（推奨）

`~/.claude/plugins/` に配置すると、すべてのセッションで自動的に有効になります。

```bash
git clone https://github.com/rce13/claude-ntfy-plugin.git ~/.claude/plugins/claude-ntfy
```

### 方法B: 一時的に試す

```bash
git clone https://github.com/rce13/claude-ntfy-plugin.git
claude --plugin-dir ./claude-ntfy-plugin
```

この方法では `--plugin-dir` を付けて起動したときだけ有効です。

---

## ステップ 2: ntfyアプリのインストール（スマホ側）

### Android

1. [Google Play Store](https://play.google.com/store/apps/details?id=io.heckel.ntfy) からntfyをインストール
2. アプリを開く
3. 右下の **＋** ボタンをタップ
4. トピック名を入力（次のステップで決めます）
5. **購読する** をタップ

### iOS

1. [App Store](https://apps.apple.com/app/ntfy/id1625396347) からntfyをインストール
2. アプリを開く
3. **＋** ボタンをタップ
4. トピック名を入力
5. **Subscribe** をタップ

---

## ステップ 3: トピック名の設定

### トピック名について

ntfy.shのトピックは **公開URL** です。トピック名を知っている人は誰でもそのトピックの通知を見ることができます。そのため、**推測されにくいユニークな名前** を使ってください。

良い例:
- `myname-claude-a8f3b2`
- `john-cc-notify-x9k2m`

悪い例:
- `claude-code`（誰でも推測できる）
- `test`（一般的すぎる）

### 方法A: 対話的セットアップ（推奨）

Claude Codeを起動して以下を入力:

```
/setup-ntfy
```

Claudeが対話的にトピック名を聞いてくれます。

### 方法B: 手動設定

```bash
mkdir -p ~/.claude-ntfy
cat > ~/.claude-ntfy/config << 'EOF'
CLAUDE_NTFY_TOPIC="ここにあなたのトピック名"
CLAUDE_NTFY_DELAY=300
CLAUDE_NTFY_SERVER="ntfy.sh"
EOF
```

### テスト通知の送信

設定が正しいか確認するため、テスト通知を送信します:

```bash
curl -s -H "Title: Claude Code" -d "Setup complete!" ntfy.sh/あなたのトピック名
```

スマホに通知が届けば成功です。

---

## ステップ 4: Remote Control の有効化（推奨）

Remote Controlを有効にすると、通知をタップしてスマホから直接Claude Codeを操作できます。

### 設定方法

Claude Code内で:

```
/config
```

表示されるメニューから **「Enable Remote Control for all sessions」** を有効にしてください。

### Remote Controlの初回設定

初めて使う場合は、QRコードの読み取りが必要な場合があります:

1. Claude Code内で `/remote-control` を実行
2. 表示されるQRコードをスマホのClaude アプリで読み取り
3. 以降は自動で接続されます

---

## 設定項目

`~/.claude-ntfy/config` で以下の項目をカスタマイズできます:

| 変数 | 説明 | デフォルト |
|------|------|-----------|
| `CLAUDE_NTFY_TOPIC` | ntfy.shのトピック名（必須） | なし |
| `CLAUDE_NTFY_DELAY` | 通知までの待機秒数 | `300`（5分） |
| `CLAUDE_NTFY_SERVER` | ntfyサーバーURL | `ntfy.sh` |

### 例: 通知を2分に短縮

```bash
cat > ~/.claude-ntfy/config << 'EOF'
CLAUDE_NTFY_TOPIC="myname-claude-a8f3b2"
CLAUDE_NTFY_DELAY=120
CLAUDE_NTFY_SERVER="ntfy.sh"
EOF
```

---

## アップデート

プラグインを最新版に更新するには:

```bash
cd ~/.claude/plugins/claude-ntfy
git pull
```

---

## アンインストール

```bash
rm -rf ~/.claude/plugins/claude-ntfy
rm -rf ~/.claude-ntfy
```

---

## トラブルシューティング

### 通知が届かない

1. **トピック名の確認**: `~/.claude-ntfy/config` のトピック名とntfyアプリで購読しているトピック名が一致しているか確認
2. **手動テスト**: `curl -s -H "Title: test" -d "hello" ntfy.sh/あなたのトピック名` を実行して通知が届くか確認
3. **jqの確認**: `jq --version` でインストール済みか確認。なければ `sudo apt install jq` (Ubuntu) や `brew install jq` (macOS) でインストール

### Remote ControlのURLが通知に含まれない

- Remote Controlが有効になっているか確認（`/config` で確認）
- セッション開始後にRemote Controlが接続されてからでないとURLは取得できません

### 通知が多すぎる

`CLAUDE_NTFY_DELAY` を大きな値に変更してください（例: `600` で10分）

---

## セルフホストntfyサーバー

プライバシーが気になる場合は、ntfyサーバーをセルフホストできます:

```bash
# Dockerで起動
docker run -p 8080:80 binwiederhier/ntfy serve

# configで自分のサーバーを指定
cat > ~/.claude-ntfy/config << 'EOF'
CLAUDE_NTFY_TOPIC="my-topic"
CLAUDE_NTFY_DELAY=300
CLAUDE_NTFY_SERVER="https://ntfy.example.com"
EOF
```

詳細: https://docs.ntfy.sh/install/

---

## ntfy.shの制限事項

- 無料枠: 1日250通知まで
- メッセージサイズ: 最大4096バイト
- トピックは公開（セルフホストなら認証設定可能）

---

## ライセンス

MIT - 自由に使用・改変・再配布できます。
