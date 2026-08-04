#!/usr/bin/env bash
# on-irreversible-action.sh — 不可逆操作前要求人工确认（生命周期 Hook · v4.2）
# 用法: bash hooks/on-irreversible-action.sh <action-description> [project-root]
set -euo pipefail
ACTION="${1:?用法: on-irreversible-action.sh <action>}"
ROOT="${2:-.}"
MEM="$ROOT/.6a-memory"
ts=$(date '+%Y-%m-%d %H:%M:%S (UTC+8)')
echo "[hook] ⚠️ 即将执行不可逆操作: $ACTION"
echo "[hook] 与阶段4 三级制联动 —— 此操作须人工确认后方可执行。"
echo "[hook] 请用户回复"确认"后继续；未确认不得执行。"
if [ -d "$MEM" ]; then
  session=$(ls -t "$MEM/session"/*.md 2>/dev/null | head -1 || true)
  [ -n "$session" ] && cat >> "$session" <<EOF

### [ASK] 不可逆操作待确认: $ACTION
- **时间**: $ts
- **详情**: on-irreversible-action 触发，等待人工确认
EOF
fi
# 此脚本只负责登记与提示；实际确认由模型在对话中获取后写 [APPROVE]
exit 0
