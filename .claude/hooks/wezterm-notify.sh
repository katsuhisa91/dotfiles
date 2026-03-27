#!/bin/bash
set -euo pipefail

PANE_ID="${WEZTERM_PANE:-}"

# WezTerm以外で実行された場合は何もしない
if [ -z "$PANE_ID" ]; then
  exit 0
fi

# hookのペイロードを標準入力から読み取る
PAYLOAD=$(cat)
EVENT=$(echo "$PAYLOAD" | jq -r '.hook_event_name // "unknown"' 2>/dev/null || echo "unknown")

# イベントに応じてステータスを決定
case "$EVENT" in
  Notification)
    STATUS="waiting"
    ;;
  Stop)
    STATUS="done"
    ;;
  *)
    STATUS="unknown"
    ;;
esac

# WezTermが読み取るためのJSONファイルを書き出す
NOTIFY_DIR="/tmp/wezterm-notifications"
mkdir -p "$NOTIFY_DIR"
cat > "$NOTIFY_DIR/$PANE_ID.json" <<EOF
{"status":"$STATUS","timestamp":$(date +%s)}
EOF

exit 0
