# evals/files/ — 用例配套输入素材

每个子目录以用例 ID 命名（如 `E004/`、`E006/`），存放该用例的 fixture：

- `E004/` — 记忆中断恢复用例的预置 `.6a-memory/` 快照
- `E006/` — 反指标用例的"刷分"代码样本（含 TODO 占位 + 空断言）

实际跑回归时由 runner 按 `cases.json` 的 `required_files` / `precondition` 取用。
