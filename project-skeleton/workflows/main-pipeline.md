# workflows/main-pipeline.md — 静态六阶段骨架

> 外层是 **Static Graph**：编译期显式声明的控制流，刚性、安全、可预测。不可跳过、不可动态重组。

## 阶段顺序与门控
1. **Align** → 模糊需求变精确规范。产出 `ALIGNMENT_*.md` + `CONSENSUS_*.md`。
2. **Architect** → 共识变系统设计。产出 `DESIGN_*.md`。
3. **Atomize** → 大任务变可执行子任务。产出 `TASK_*.md`。
4. **Approve** → 人工审查确认（HITL 锚点）。收到明确"确认"才进入 5。
5. **Automate** → 按文档编码实现（内部允许 Dynamic Inner Loop）。产出代码 + `ACCEPTANCE_*.md`。
6. **Assess** → 质量验收交付（审计环 + 反指标环）。产出 `FINAL_*.md` + `TODO_*.md` + `TRACE_*.md`。

## 跳出条件（每个阶段）
- 质量门控全过 → 进入下一阶段。
- 任一不过 → **循环回退本阶段起点重做**（具体回退点见仓库根 `6A.md`）。

## 边治理（可靠性活在边上）
- 规划→执行：须 Approve 签收。
- 执行→评估：须 PR + CI 门禁通过。
- 评估→规划（回环）：反馈须结构化到任务编号 + 原因。

## 文档存放
```
docs/任务名/
  ALIGNMENT_*.md  CONSENSUS_*.md  DESIGN_*.md  TASK_*.md
  ACCEPTANCE_*.md  FINAL_*.md  TODO_*.md  TRACE_*.md
```
