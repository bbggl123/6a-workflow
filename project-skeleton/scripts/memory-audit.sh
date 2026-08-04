#!/usr/bin/env bash
# memory-audit.sh — 记忆完整性自检（确定性优先交给代码 · v4.2）
# 扫描 .6a-memory/session/ 时间戳连续性 + 关键动作条目完整性，输出缺口报告。
# 用法：bash scripts/memory-audit.sh [project-root]
# 退出码：0=通过 1=有缺口 2=记忆目录不存在
set -euo pipefail

ROOT="${1:-.}"
MEM="$ROOT/.6a-memory"

if [ ! -d "$MEM/session" ]; then
  echo "[memory-audit] 未找到 $MEM/session —— 记忆系统未部署或为 trivial 任务（可跳过）"
  exit 2
fi

echo "=== 6A 记忆完整性自检 ==="
issues=0

# 1. 检查 INDEX.md 存在
if [ ! -f "$MEM/INDEX.md" ]; then
  echo "[MISS] INDEX.md 缺失 —— 记忆总索引不存在"
  issues=$((issues+1))
fi

# 2. 检查 progress/current-phase.md 存在
if [ ! -f "$MEM/progress/current-phase.md" ]; then
  echo "[MISS] progress/current-phase.md 缺失 —— 无法恢复当前阶段"
  issues=$((issues+1))
fi

# 3. session 时间戳连续性：从文件名提取时间，检查相邻 session 间隔
sessions=$(ls "$MEM/session"/*.md 2>/dev/null | sort)
if [ -z "$sessions" ]; then
  echo "[MISS] session/ 下无会话日志"
  issues=$((issues+1))
else
  prev_ts=""
  for f in $sessions; do
    # 文件名形如 2026-08-04-203410.md
    base=$(basename "$f" .md)
    ts=$(echo "$base" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{6}$' || true)
    if [ -z "$ts" ]; then
      echo "[WARN] session 文件名不规范: $base（应为 YYYY-MM-DD-HHMMSS.md）"
      issues=$((issues+1))
      continue
    fi
    if [ -n "$prev_ts" ]; then
      # 粗略检查日期是否倒退
      if [[ "$ts" < "$prev_ts" ]]; then
        echo "[GAP] session 时间倒退: $prev_ts -> $ts"
        issues=$((issues+1))
      fi
    fi
    prev_ts="$ts"
  done
fi

# 4. 检查关键动作类型覆盖（每阶段至少应有 CHECKPOINT）
latest_session=$(ls -t "$MEM/session"/*.md 2>/dev/null | head -1 || true)
if [ -n "$latest_session" ]; then
  for act in CHECKPOINT DECIDE MODIFY RUN; do
    if ! grep -q "\[$act\]" "$latest_session"; then
      echo "[WARN] 最近 session 缺少 [$act] 动作条目 —— 可能记忆不完整"
      issues=$((issues+1))
    fi
  done
fi

echo "---"
if [ "$issues" -eq 0 ]; then
  echo "[PASS] 记忆完整性自检通过"
  exit 0
else
  echo "[FAIL] 发现 $issues 处缺口，请补记后再过门控"
  exit 1
fi
