# claude-ntfy Installation Guide

Ever left Claude Code running a long task, only to realize it's been waiting for your approval for the past 30 minutes?

**claude-ntfy** is a Claude Code plugin that sends push notifications to your phone when Claude Code needs your attention. It uses [ntfy.sh](https://ntfy.sh) — no account required, completely free.

## Who is this for?

- You run Claude Code tasks and switch to other work
- You don't want to waste time with unnoticed approval prompts
- You want to operate Claude Code from your phone (via Remote Control)

## How it works

```
Claude Code waiting for approval
  |
Notification hook fires
  |
Marker file created + 5-minute timer starts
  |
+-- User responds within 5 min --> Marker deleted --> No notification
+-- No response for 5 min ------> ntfy.sh notification --> Phone alert
                                                              |
                                                          Tap notification
                                                              |
                                                          Remote Control session
```

- **5-minute delay**: Notifications are sent only after 5 minutes of inactivity (no spam)
- **Auto-cancel**: If you respond within 5 minutes, the notification is cancelled
- **Remote Control**: Notification includes a direct session URL for phone-based control

---

## Prerequisites

| Requirement | Details |
|-------------|---------|
| Claude Code | v2.1.51 or later |
| ntfy app | Android or iOS |
| jq | Pre-installed on most Linux/macOS systems |
| curl | Pre-installed on most systems |

---

## Step 1: Install the Plugin

### Option A: Permanent install (recommended)

Place the plugin in `~/.claude/plugins/` so it loads automatically in every session:

```bash
git clone https://github.com/rce13/claude-ntfy-plugin.git ~/.claude/plugins/claude-ntfy
```

### Option B: Try it temporarily

```bash
git clone https://github.com/rce13/claude-ntfy-plugin.git
claude --plugin-dir ./claude-ntfy-plugin
```

This only works when you start Claude Code with the `--plugin-dir` flag.

---

## Step 2: Install the ntfy App (Phone)

### Android

1. Install ntfy from [Google Play Store](https://play.google.com/store/apps/details?id=io.heckel.ntfy)
2. Open the app
3. Tap the **+** button (bottom right)
4. Enter your topic name (you'll choose this in the next step)
5. Tap **Subscribe**

### iOS

1. Install ntfy from [App Store](https://apps.apple.com/app/ntfy/id1625396347)
2. Open the app
3. Tap the **+** button
4. Enter your topic name
5. Tap **Subscribe**

---

## Step 3: Configure Your Topic Name

### About topic names

ntfy.sh topics are **public URLs**. Anyone who knows the topic name can see notifications sent to it. Use a **unique, hard-to-guess name**.

Good examples:
- `myname-claude-a8f3b2`
- `john-cc-notify-x9k2m`

Bad examples:
- `claude-code` (easily guessable)
- `test` (too common)

### Option A: Interactive setup (recommended)

Start Claude Code and type:

```
/setup-ntfy
```

Claude will guide you through the setup interactively.

### Option B: Manual configuration

```bash
mkdir -p ~/.claude-ntfy
cat > ~/.claude-ntfy/config << 'EOF'
CLAUDE_NTFY_TOPIC="your-unique-topic-name"
CLAUDE_NTFY_DELAY=300
CLAUDE_NTFY_SERVER="ntfy.sh"
EOF
```

### Send a test notification

Verify your setup:

```bash
curl -s -H "Title: Claude Code" -d "Setup complete!" ntfy.sh/your-topic-name
```

If you receive a notification on your phone, you're all set.

---

## Step 4: Enable Remote Control (Recommended)

Remote Control lets you operate Claude Code directly from your phone when you tap a notification.

### How to enable

In Claude Code, run:

```
/config
```

Select **"Enable Remote Control for all sessions"**.

### First-time Remote Control setup

If this is your first time using Remote Control:

1. Run `/remote-control` in Claude Code
2. Scan the QR code with the Claude app on your phone
3. Future sessions will connect automatically

---

## Configuration

Customize settings in `~/.claude-ntfy/config`:

| Variable | Description | Default |
|----------|-------------|---------|
| `CLAUDE_NTFY_TOPIC` | ntfy.sh topic name (required) | none |
| `CLAUDE_NTFY_DELAY` | Seconds to wait before sending notification | `300` (5 min) |
| `CLAUDE_NTFY_SERVER` | ntfy server URL | `ntfy.sh` |

### Example: Reduce delay to 2 minutes

```bash
cat > ~/.claude-ntfy/config << 'EOF'
CLAUDE_NTFY_TOPIC="myname-claude-a8f3b2"
CLAUDE_NTFY_DELAY=120
CLAUDE_NTFY_SERVER="ntfy.sh"
EOF
```

---

## Updating

Pull the latest version:

```bash
cd ~/.claude/plugins/claude-ntfy
git pull
```

---

## Uninstalling

```bash
rm -rf ~/.claude/plugins/claude-ntfy
rm -rf ~/.claude-ntfy
```

---

## Troubleshooting

### Not receiving notifications

1. **Check topic name**: Make sure the topic in `~/.claude-ntfy/config` matches what you subscribed to in the ntfy app
2. **Manual test**: Run `curl -s -H "Title: test" -d "hello" ntfy.sh/your-topic-name` and check your phone
3. **Check jq**: Run `jq --version`. If not installed: `sudo apt install jq` (Ubuntu) or `brew install jq` (macOS)

### Remote Control URL not included in notifications

- Verify Remote Control is enabled (check with `/config`)
- The URL is only available after Remote Control connects at session start

### Too many notifications

Increase `CLAUDE_NTFY_DELAY` in your config (e.g., `600` for 10 minutes).

---

## Self-hosted ntfy Server

For privacy, you can self-host your own ntfy server:

```bash
# Run with Docker
docker run -p 8080:80 binwiederhier/ntfy serve

# Point your config to your server
cat > ~/.claude-ntfy/config << 'EOF'
CLAUDE_NTFY_TOPIC="my-topic"
CLAUDE_NTFY_DELAY=300
CLAUDE_NTFY_SERVER="https://ntfy.example.com"
EOF
```

Details: https://docs.ntfy.sh/install/

---

## ntfy.sh Limitations

- Free tier: 250 notifications per day
- Message size: 4096 bytes max
- Topics are public (self-hosted supports authentication)

---

## License

MIT — free to use, modify, and redistribute.
