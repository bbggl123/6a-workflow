#!/usr/bin/env bash
# on-phase-enter.sh — 进入阶段时触发（生命周期 Hook · v4.2）
# 用法: bash hooks/on-phase-enter.sh <Phase> [project-root]
set -euo pipefail
PHASE="${1:?用法: on-phase-enter.sh <Phase>}"
ROOT="${2:-.}"
MEM="$ROOT/.6a-memory"
[ -d "$MEM" ] || { echo "[hook] .6a-memory/ 不存在，跳过（trivial 任务）"; exit 0; }
ts=$(date '+%Y-%m-%d %H:%M:%S (UTC+8)')
session=$(ls -t "$MEM/session"/*.md 2>/dev/null | head -1 || true)
[ -n "$session" ] || { echo "[hook] 无 session 日志，跳过"; exit 0; }
cat >> "$session" <<EOF

### [CHECKPOINT] 进入阶段$PHASE
- **时间**: $ts
- **阶段**: $PHASE
- **角色**: 当前调度角色
- **详情**: 生命周期 Hook on-phase-enter 触发
EOF
cat > "$MEM/progress/current-phase.md" <<EOF
# 当前阶段
- **阶段**: $PHASE
- **更新时间**: $ts
EOF
echo "[hook] on-phase-enter: $PHASE 已记录"
