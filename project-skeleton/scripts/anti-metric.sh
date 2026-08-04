#!/usr/bin/env bash
# anti-metric.sh — 反指标计算（确定性优先交给代码 · v4.2）
# 计算阶段6 反指标检查所需的具体数值：TODO 占位率、空断言率、硬编码数。
# 用法：bash scripts/anti-metric.sh <src-dir-or-file>...
# 退出码：0=健康 1=有反指标告警 2=未提供目标
set -euo pipefail

if [ $# -eq 0 ]; then
  echo "用法: anti-metric.sh <src-dir-or-file>..."
  echo "示例: anti-metric.sh src/ tests/"
  exit 2
fi

echo "=== 6A 反指标计算（Anti-Goodhart） ==="

todo_count=0
hardcode_count=0
assert_total=0
empty_assert=0

for target in "$@"; do
  # TODO 占位：扫 TODO/FIXME/XXX/NotImplemented/pass 占位
  if [ -d "$target" ] || [ -f "$target" ]; then
    t=$(grep -rInE 'TODO|FIXME|XXX|NotImplemented|^\s*pass\s*$' "$target" 2>/dev/null | wc -l || echo 0)
    todo_count=$((todo_count + t))
    # 硬编码密码/密钥粗扫
    h=$(grep -rInE '(password|passwd|secret|api_key|apikey|token)\s*[:=]\s*["\x27][^"\x27]{6,}' "$target" 2>/dev/null | grep -viE '\.env|getenv|os\.environ|process\.env|config\.' | wc -l || echo 0)
    hardcode_count=$((hardcode_count + h))
    # 空断言：assert True / assert result is not None（无后续使用）
    a=$(grep -rInE 'assert\s+(True|False|result\s+is\s+(not\s+)?None)\s*$' "$target" 2>/dev/null | wc -l || echo 0)
    empty_assert=$((empty_assert + a))
    at=$(grep -rInE '^\s*assert\s+' "$target" 2>/dev/null | wc -l || echo 0)
    assert_total=$((assert_total + at))
  fi
done

empty_rate="N/A"
if [ "$assert_total" -gt 0 ]; then
  empty_rate=$(awk "BEGIN{printf \"%.1f%%\", $empty_assert/$assert_total*100}")
fi

echo "TODO/FIXME/占位数: $todo_count"
echo "疑似硬编码凭据数: $hardcode_count"
echo "断言总数 / 空断言数: $assert_total / $empty_assert （空断言率 $empty_rate）"
echo "---"

alarm=0
[ "$todo_count" -gt 0 ] && { echo "[ALARM] TODO 占位 > 0 —— 功能完成率指标可能被刷分"; alarm=1; }
[ "$hardcode_count" -gt 0 ] && { echo "[ALARM] 疑似硬编码凭据 > 0 —— 安全风险"; alarm=1; }
if [ "$assert_total" -gt 0 ] && [ "$empty_assert" -gt 0 ]; then
  echo "[ALARM] 存在空断言 —— 测试通过率指标可能被刷分"; alarm=1
fi

if [ "$alarm" -eq 0 ]; then
  echo "[PASS] 反指标健康"
  exit 0
else
  echo "[FAIL] 反指标告警 —— 计入阶段6 REWORK"
  exit 1
fi
