#!/usr/bin/env bash
# on-gate-fail.sh — 门控失败时触发（生命周期 Hook · v4.2）
# 用法: bash hooks/on-gate-fail.sh <Phase> <reason> [project-root]
set -euo pipefail
PHASE="${1:?用法: on-gate-fail.sh <Phase> <reason>}"
REASON="${2:?需提供失败原因}"
ROOT="${3:-.}"
MEM="$ROOT/.6a-memory"
[ -d "$MEM" ] || { echo "[hook] .6a-memory/ 不存在，跳过"; exit 0; }
ts=$(date '+%Y-%m-%d %H:%M:%S (UTC+8)')
session=$(ls -t "$MEM/session"/*.md 2>/dev/null | head -1 || true)
[ -n "$session" ] && cat >> "$session" <<EOF

### [ERROR] 阶段$PHASE 门控失败
- **时间**: $ts
- **阶段**: $PHASE
- **详情**: $REASON —— 循环回退本阶段起点重做
EOF
blk="$MEM/progress/blockers.md"
[ -f "$blk" ] || echo "# 阻塞项" > "$blk"
echo "- [$ts] $PHASE 门控失败: $REASON" >> "$blk"
echo "[hook] on-gate-fail: $PHASE 失败原因已记录，开始循环回退"
