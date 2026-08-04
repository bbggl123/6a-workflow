#!/usr/bin/env bash
# credibility-lint.sh — 可信度标注四行完整性 + 区间合法性校验（确定性优先交给代码 · v4.2）
# 扫描指定 docs 产出文件，检查每条可信度标注是否四行齐全、百分比落在合法区间。
# 用法：bash scripts/credibility-lint.sh <docs-dir-or-file>...
# 退出码：0=通过 1=有违规 2=未提供目标
set -euo pipefail

if [ $# -eq 0 ]; then
  echo "用法: credibility-lint.sh <docs-dir-or-file>..."
  echo "示例: credibility-lint.sh docs/任务名/CONSENSUS_xxx.md docs/任务名/DESIGN_xxx.md"
  exit 2
fi

echo "=== 6A 可信度标注校验 ==="
violations=0
checked=0

check_file() {
  local f="$1"
  [ -f "$f" ] || return 0
  # 用 awk 按【回答可信度】分块
  awk '
    /【回答可信度】/ { block=""; inblock=1 }
    inblock { block = block $0 "\n" }
    /【使用建议】/ && inblock {
      inblock=0
      # 提取百分比
      pct=""
      if (match(block, /【回答可信度】[[:space:]]*([0-9]+)%/, m)) pct=m[1]
      # 四行完整性
      has_src = (block ~ /【内容来源】/)
      has_gap = (block ~ /【信息盲区】/)
      has_adv = (block ~ /【使用建议】/)
      printf "[CHECK] %s 标注块 pct=%s src=%d gap=%d adv=%d\n", FILENAME, pct, has_src, has_gap, has_adv
      if (!has_src || !has_gap || !has_adv) { print "  [VIOLATION] 四行不完整"; exit_code=1 }
      if (pct != "" && (pct+0 < 0 || pct+0 > 100)) { print "  [VIOLATION] 百分比越界"; exit_code=1 }
      # 数值与来源矛盾：标 90% 却来源"逻辑推测"
      if (pct+0 >= 90 && block ~ /逻辑推测/) { print "  [VIOLATION] 标" pct "% 却来源逻辑推测 —— 标注失真"; exit_code=1 }
      checked++
    }
    END { if (checked==0) print "[WARN] " FILENAME " 未发现任何可信度标注块" }
  ' exit_code=0 "$f" || violations=$((violations+1))
}

for target in "$@"; do
  if [ -d "$target" ]; then
    while IFS= read -r f; do check_file "$f"; done < <(find "$target" -name '*.md' -type f)
  else
    check_file "$target"
  fi
done

echo "---"
if [ "$violations" -eq 0 ]; then
  echo "[PASS] 可信度标注校验通过"
  exit 0
else
  echo "[FAIL] 发现 $violations 处违规，补标后再过门控"
  exit 1
fi
