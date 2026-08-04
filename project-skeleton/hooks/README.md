# hooks/ — 生命周期 Hook 脚本（v4.2 新增）

> 课程原则：Hook 在开始、完成、失败等节点自动触发固定动作，不依赖模型每步自觉执行。
> 完整 Hook 定义见 `references/6A-hooks.md`。本目录承载可确定性执行的部分；模型在各阶段边界显式调用。

## 四类触发点

| Hook 脚本 | 触发时机 | 动作 |
|---|---|---|
| `on-phase-enter.sh <phase>` | 进入某阶段 | 写记忆 `[CHECKPOINT] 进入阶段X` + 更新 `progress/current-phase.md` |
| `on-phase-exit.sh <phase>` | 阶段门控通过 | 写 `[CHECKPOINT] 阶段X 完成` + 更新 `completed.md` |
| `on-gate-fail.sh <phase> <reason>` | 门控不过 | 记录失败原因到 `blockers.md` + 写 `[ERROR]` |
| `on-irreversible-action.sh <action>` | 删除/迁移/部署前 | 要求人工确认（与阶段4 三级制联动）+ 写 `[APPROVE]` |

## 降级策略

- 平台支持原生 Hook → 优先用平台回调注册上述触发点。
- 无原生 Hook → 模型在阶段边界显式 `bash hooks/on-phase-enter.sh Align` 调用，**不得静默跳过**。
- 平台与脚本均不可用 → 模型显式执行固定动作，违反即门控不通过。

## 用法

```bash
bash hooks/on-phase-enter.sh Align      # 进入阶段1
bash hooks/on-phase-exit.sh Architect   # 阶段2 门控通过
bash hooks/on-gate-fail.sh Atomize "依赖循环"  # 阶段3 门控失败
bash hooks/on-irreversible-action.sh "删除 users 表"
```

脚本默认操作项目根的 `.6a-memory/`；若不存在会提示先部署记忆系统（trivial 任务跳过）。
