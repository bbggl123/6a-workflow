#!/usr/bin/env bash
# on-phase-exit.sh — 阶段门控通过时触发（生命周期 Hook · v4.2）
# 用法: bash hooks/on-phase-exit.sh <Phase> [project-root]
set -euo pipefail
PHASE="${1:?用法: on-phase-exit.sh <Phase>}"
ROOT="${2:-.}"
MEM="$ROOT/.6a-memory"
[ -d "$MEM" ] || { echo "[hook] .6a-memory/ 不存在，跳过"; exit 0; }
ts=$(date '+%Y-%m-%d %H:%M:%S (UTC+8)')
session=$(ls -t "$MEM/session"/*.md 2>/dev/null | head -1 || true)
[ -n "$session" ] && cat >> "$session" <<EOF

### [CHECKPOINT] 阶段$PHASE 完成
- **时间**: $ts
- **阶段**: $PHASE
- **详情**: 质量门控通过，on-phase-exit 触发
EOF
comp="$MEM/progress/completed.md"
[ -f "$comp" ] || echo "# 已完成阶段" > "$comp"
echo "- [$ts] $PHASE —— 门控通过" >> "$comp"
echo "[hook] on-phase-exit: $PHASE 已记录完成，请向用户同步阶段完成"
