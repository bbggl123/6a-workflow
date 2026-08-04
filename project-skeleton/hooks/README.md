# hooks/ — 生命周期 Hook 脚本（v4.2 新增 · v4.3 增 on-task-complete）

> 课程原则：Hook 在开始、完成、失败等节点自动触发固定动作，不依赖模型每步自觉执行。
> 完整 Hook 定义见 `references/6A-hooks.md`。本目录承载可确定性执行的部分；模型在各阶段/任务边界显式调用。

## 五类触发点

| Hook 脚本 | 触发时机 | 动作 |
|---|---|---|
| `on-phase-enter.sh <phase>` | 进入某阶段 | 写记忆 `[CHECKPOINT] 进入阶段X` + 更新 `progress/current-phase.md` |
| `on-phase-exit.sh <phase>` | 阶段门控通过 | 写 `[CHECKPOINT] 阶段X 完成` + 更新 `completed.md` |
| `on-gate-fail.sh <phase> <reason>` | 门控不过 | 记录失败原因到 `blockers.md` + 写 `[ERROR]` |
| `on-irreversible-action.sh <action>` | 删除/迁移/部署前 | 要求人工确认（与阶段4 三级制联动）+ 写 `[APPROVE]` |
| `on-task-complete.sh <task_id> <session_log> <task_doc> [docs_dir]`（v4.3 新增） | 阶段5 单任务 Txx 完成 | 校验实质产出 vs 契约 + progress 勾选 + 检测「假象」+ 提醒派发后续任务 |

## 降级策略

- 平台支持原生 Hook → 优先用平台回调注册上述触发点。
- 无原生 Hook → 模型在阶段/任务边界显式 `bash hooks/on-phase-enter.sh Align` 调用，**不得静默跳过**。
- 平台与脚本均不可用 → 模型显式执行固定动作，违反即门控不通过。

## 用法

```bash
bash hooks/on-phase-enter.sh Align      # 进入阶段1
bash hooks/on-phase-exit.sh Architect   # 阶段2 门控通过
bash hooks/on-gate-fail.sh Atomize "依赖循环"  # 阶段3 门控失败
bash hooks/on-irreversible-action.sh "删除 users 表"
bash hooks/on-task-complete.sh T03 .6a-memory/session/2026-08-04.md docs/login/TASK_login.md docs/login  # 阶段5 任务 T03 完成
```

脚本默认操作项目根的 `.6a-memory/`；若不存在会提示先部署记忆系统（trivial 任务跳过）。
