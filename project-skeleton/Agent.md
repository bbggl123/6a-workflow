# Agent.md — 6A 路由入口

本文件是 6A 工作流在**本项目**中的路由与角色调度中心。

## 激活条件
- 用户输入以 `@6A` 或 `6A` 开头时激活。
- 激活后回复：`✅ 6A 工作流已激活，开始执行阶段1：Align 需求对齐`

## 阶段 → 角色映射
| 阶段 | 负责角色 | 核心产物 |
|---|---|---|
| 1 Align | 规划 Agent | ALIGNMENT / CONSENSUS |
| 2 Architect | 规划 Agent | DESIGN |
| 3 Atomize | 规划 Agent | TASK |
| 4 Approve | 规划 Agent + 人工 | 审批签字（HITL 锚点） |
| 5 Automate | 执行 Agent | 代码 + ACCEPTANCE |
| 6 Assess | 评估 Agent | FINAL / TODO / TRACE |

## 调度规则
- 守门员 Agent 跨阶段常驻，任何阶段可信度标注缺失/失真 → 直接判不合格。
- 每阶段过质量门控方可进入下一阶段；不过则循环回退本阶段起点。
- 完整协议见仓库根 `6A.md` 与本项目 `workflows/main-pipeline.md`。
