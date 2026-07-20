# readme.md — 6A 执行边界与维护规则

## 执行边界（Execution Boundary）
- 本目录下的 `agents/`、`workflows/`、`knowledge/`、`tools/` 是 **6A 工作流的配置与记忆**，不是业务代码。
- 单 Agent 会话中以"角色切换"模拟多 Agent，但职责边界必须显式声明、不可混用。

## 完成证据（Completion Evidence）
每个阶段结束须产出对应文档并存于 `docs/任务名/`：
- 阶段1：`ALIGNMENT_*.md` + `CONSENSUS_*.md`
- 阶段2：`DESIGN_*.md`
- 阶段3：`TASK_*.md`
- 阶段5：`ACCEPTANCE_*.md`
- 阶段6：`FINAL_*.md` + `TODO_*.md` + `TRACE_*.md`

## 阶段门控（Quality Gate）
- 门控不过 → 循环回退本阶段起点重做，禁止带病进入下一阶段。
- 任何对外输出缺可信度标注 → 视为未完成。

## 巡视与维护（Maintenance）
- 每个新任务启动前先读取 `knowledge/` 红线库与反模式库，避免重复踩坑。
- 任务结束后将新发现的红线 / 教训 / 成功模式沉淀回 `knowledge/`。
- `TRACE_*.md` 是唯一可信的全程留痕，须与 LOG 编号一一对应。
