#!/usr/bin/env bash
# ref-reset-detect.sh — git 引用重置检测（确定性优先交给代码 · v4.2）
# 比对 git reflog，检测活动分支引用是否被环境悄悄挪回更早提交（提交"消失"）。
# 用法：bash scripts/ref-reset-detect.sh [repo-root] [branch]
# 退出码：0=未检测到重置 1=检测到引用回退 2=非 git 仓库
set -euo pipefail

ROOT="${1:-.}"
BRANCH="${2:-HEAD}"

cd "$ROOT"
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[ref-reset-detect] 非 git 仓库，跳过"
  exit 2
fi

echo "=== 6A Git 引用重置检测 ==="
echo "目标: $BRANCH"

# reflog 最近 N 条，看是否有 reset/move 操作把引用指向了更早的提交
reset_count=$(git reflog --pretty='%gs' 2>/dev/null | grep -ciE 'reset|moving to|checkout: moving from' || true)

# 关键检测：当前 HEAD 是否在 reflog 中曾出现过更高的位置（被回退）
current=$(git rev-parse HEAD 2>/dev/null || echo "")
prev_heads=$(git reflog --pretty='%H' 2>/dev/null | head -20 || true)

if [ -z "$current" ] || [ -z "$prev_heads" ]; then
  echo "[WARN] 无法读取 reflog（可能是浅克隆或无 reflog），跳过深度检测"
  exit 0
fi

# 检查当前 HEAD 是否比 reflog 中记录过的某些提交更老（被回退的信号）
reverted=0
while read -r h; do
  [ "$h" = "$current" ] && continue
  # 如果 current 是 h 的祖先，说明 h 曾是 HEAD 但被回退到 current
  if git merge-base --is-ancestor "$current" "$h" 2>/dev/null; then
    reverted=$((reverted+1))
  fi
done <<< "$prev_heads"

echo "reflog 中的 reset/move 类操作数: $reset_count"
echo "检测到的潜在引用回退次数: $reverted"

if [ "$reverted" -gt 0 ]; then
  echo "[FAIL] 检测到活动引用可能被环境挪回更早提交 —— Worker 应守「消失即停」，Lead 用 tag + reset --soft 非破坏恢复（见 references/6A-git-shield.md 7.8.2）"
  exit 1
else
  echo "[PASS] 未检测到引用回退"
  exit 0
fi
