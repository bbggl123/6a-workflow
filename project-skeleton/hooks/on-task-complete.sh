#!/usr/bin/env bash
# on-task-complete.sh — 任务粒度检查点 Hook（v4.3 新增）
#
# 触发时机：阶段5 单个原子任务 Txx 标记完成时
# 用法：   bash hooks/on-task-complete.sh <task_id> <session_log> <task_doc> [docs_dir]
#   task_id     : 任务编号，如 T03
#   session_log : .6a-memory/session/ 下当前 session 日志路径
#   task_doc    : docs/任务名/TASK_任务名.md（含交付物清单与并行标注）
#   docs_dir    : docs/任务名/（交付物所在目录，默认与 task_doc 同目录）
#
# 固定动作：
#   1. 校验实质产出 vs TASK 契约（文件改动 / 测试 / 验证结果）
#   2. progress/ 勾选 [ ]→[x] 并刷新任务清单状态
#   3. 检测「制造干活的假象」——留痕密集但无实质产出
#   4. 若该任务是后续「可并行 / 依赖前置」任务的前置，提醒派发后续任务
#
# 退出码：
#   0 = 通过
#   1 = 检测到「假象」，打回重做（联动 on-gate-fail）
#   2 = 参数缺失 / 文件不存在（降级为模型显式执行）

set -euo pipefail

TASK_ID="${1:-}"
SESSION_LOG="${2:-}"
TASK_DOC="${3:-}"
DOCS_DIR="${4:-$(dirname "${TASK_DOC:-.}")}"

if [[ -z "$TASK_ID" || -z "$SESSION_LOG" || -z "$TASK_DOC" ]]; then
  echo "[on-task-complete] 缺参数：task_id / session_log / task_doc" >&2
  echo "  用法: $0 <task_id> <session_log> <task_doc> [docs_dir]" >&2
  exit 2
fi
if [[ ! -f "$SESSION_LOG" ]]; then
  echo "[on-task-complete] session 日志不存在: $SESSION_LOG（降级为模型显式执行）" >&2
  exit 2
fi
if [[ ! -f "$TASK_DOC" ]]; then
  echo "[on-task-complete] TASK 文档不存在: $TASK_DOC（降级为模型显式执行）" >&2
  exit 2
fi

REASON=""
FAIL=0

# --- 动作1：校验实质产出 vs TASK 契约 ---
# 从 TASK_DOC 提取该任务的交付物文件清单（匹配 - 交付物: / 产物: / 文件: 行后路径）
DELIVERABLES=$(grep -A 20 "^### .*${TASK_ID}" "$TASK_DOC" 2>/dev/null \
  | grep -iE '^\s*-\s.*(交付物|产物|输出|文件)' \
  | sed -E 's/.*[`"]?([^`" ]+\.[a-z0-9]+)[`"]?.*/\1/' \
  | grep -E '\.' || true)

for f in $DELIVERABLES; do
  # 交付物路径相对于 docs_dir 解析
  candidate=""
  [[ -f "$f" ]] && candidate="$f"
  [[ -z "$candidate" && -f "$DOCS_DIR/$f" ]] && candidate="$DOCS_DIR/$f"
  # 代码类交付物可能在 git diff 中
  if [[ -z "$candidate" ]]; then
    if git diff --name-only HEAD 2>/dev/null | grep -qF "$f"; then
      candidate="(git-diff) $f"
    fi
  fi
  if [[ -z "$candidate" ]]; then
    REASON="${REASON}交付物缺失: ${f}; "
    FAIL=1
  fi
done

# --- 动作3：检测「制造干活的假象」 ---
# 规则a：该任务 session 留痕 ≥3 条，但 git diff 无对应文件改动
TRACE_COUNT=$(grep -cE "\[(CHECKPOINT|MODIFY|RUN|APPROVE)\].*${TASK_ID}" "$SESSION_LOG" 2>/dev/null || echo 0)
DIFF_FILES=$(git diff --name-only HEAD 2>/dev/null || true)

if [[ "$TRACE_COUNT" -ge 3 && -z "$DIFF_FILES" ]]; then
  REASON="${REASON}假象：${TASK_ID} 留痕 ${TRACE_COUNT} 条但 git diff 无文件改动; "
  FAIL=1
fi

# 规则b：声称测试通过但无测试文件改动 / 无 [RUN] 结果
if grep -qE "${TASK_ID}.*(测试通过|test pass)" "$SESSION_LOG" 2>/dev/null; then
  HAS_TEST_DIFF=$(echo "$DIFF_FILES" | grep -ciE '(test|spec)' || echo 0)
  HAS_RUN=$(grep -cE "\[RUN\].*${TASK_ID}" "$SESSION_LOG" 2>/dev/null || echo 0)
  if [[ "$HAS_TEST_DIFF" -eq 0 && "$HAS_RUN" -eq 0 ]]; then
    REASON="${REASON}假象：${TASK_ID} 声称测试通过但无测试改动且无 [RUN] 记录; "
    FAIL=1
  fi
fi

# --- 动作2：progress/ 勾选 [ ]→[x] ---
PROGRESS_FILE=".6a-memory/progress/tasks.md"
if [[ -f "$PROGRESS_FILE" ]]; then
  # 将该任务行的 [ ] 改为 [x]
  if grep -qE "^\s*-\s*\[ \].*${TASK_ID}" "$PROGRESS_FILE"; then
    sed -i.bak -E "s/^(\s*-\s*)\[ \](.*${TASK_ID})/\1[x]\2/" "$PROGRESS_FILE"
    rm -f "${PROGRESS_FILE}.bak"
    echo "[on-task-complete] progress/tasks.md: ${TASK_ID} 勾选 [x]"
  fi
fi

# --- 动作4：提醒派发后续「依赖前置 [Txx]」任务 ---
if grep -qE "依赖前置.*${TASK_ID}" "$TASK_DOC" 2>/dev/null; then
  NEXT=$(grep -E "依赖前置.*${TASK_ID}" "$TASK_DOC" | grep -oE 'T[0-9]+' | sort -u | tr '\n' ' ')
  echo "[on-task-complete] 提醒：以下任务依赖 ${TASK_ID}，可派发: ${NEXT}"
fi

# --- 输出结论 ---
if [[ "$FAIL" -eq 1 ]]; then
  echo "[on-task-complete] ❌ ${TASK_ID} 检查不通过：${REASON}" >&2
  echo "[on-task-complete] 联动 on-gate-fail，打回 ${TASK_ID} 重做" >&2
  exit 1
fi

echo "[on-task-complete] ✅ ${TASK_ID} 实质产出校验通过（留痕 ${TRACE_COUNT} 条 / 交付物齐备）"
exit 0
