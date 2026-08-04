---
name: 6a-workflow
description: "Agentic SDLC 六阶段工作流（Align→Architect→Atomize→Approve→Automate→Assess）。当用户输入以 @6A 或 6A 开头，或要求带角色分离 / 质量门控 / 防幻觉可信度标注 / 人工审批回环的 Agent 开发流程时激活。内置项目级记忆系统、多 Agent 分支保护盾，并支持 Gauntlet Loop 并行对抗执行模式（主 Agent 拆解 → 子 Agent 并行 → 评委盲测验收 → 不达标打回循环）。完整协议见 6A.md。"
---

# 6A Workflow — WorkBuddy 适配层

> ⚠️ 本文件**只是 6A 工作流在 WorkBuddy 里的接入壳**。真正的权威协议是仓库根目录的 **`6A.md`**（与任何 Agent 平台无关）。运行 6A 前必须加载它。

## 这是什么

6A 是一套把"模糊需求"变成"可审计交付物"的 Agentic 软件开发生命周期（SDLC）工作流，形态是一张 **Grounded Graph of Loops**（静态六阶段外层骨架 + 审计环 / 反指标环 / 仲裁环 + 外部锚点）。六阶段：`Align → Architect → Atomize → Approve → Automate → Assess`。

## 何时激活

满足以下任一条件即激活：
- 用户输入以 **"@6A"** 或 **"6A"** 开头（如 `6A 帮我做一个 xxx`）。
- 用户明确要求"用 6A 工作流 / Agentic SDLC / 带门控的 Agent 开发流程"执行任务。
- 任务需要明确的角色拆分、质量门控、防幻觉可信度标注与人工审批回环。

## 激活响应

激活后：
1. 回复 `✅ 6A 工作流已激活`，并做 **triage**（判定 trivial / standard / complex，见 6A.md 第二章）。
2. **确认门槛**：standard / complex 任务在部署记忆系统（创建 `.6a-memory/`、改 `.gitignore`）前，须先向用户确认"将在项目根部署 .6a-memory/ 并修改 .gitignore，确认开始？"；trivial 任务走精简流程，跳过记忆系统与逐条可信度标注。
3. 读取并严格遵循 `6A.md`（索引壳），按需加载 `references/` 分章文件（渐进式加载，激活不全量读入）。

## 速记（索引，详情见 6A.md + references/）

- **四角色**：规划 Agent（阶段1–4）/ 执行 Agent（阶段5）/ 评估 Agent（阶段6）/ 守门员 Agent（跨阶段防幻觉 + 可信度校验 + 记忆完整性）。Gauntlet Loop 模式新增**评委 Agent**（独立盲测验收）。
- **铁律**：每阶段结束须过质量门控；不过则循环回退本阶段起点重做。
- **Constitution 共享约束层（v4.3）**：`CONSTITUTION.md` 把安全红线 / 代码质量 / 测试策略 / Gotchas 固化为单一冻结约束源，全流程共享引用，evals 评判准绳。Align 开始前必读。
- **Clarify 主动提问（v4.3）**：Align 内 AI 主动产出提问清单（未明确边界/约束/异常处理），可信度 <80% 的项必进清单，未决项不靠猜推进。
- **WHAT-only 门控（v4.3）**：Align 产出物不得含实现技术选型，技术栈留到 Architect。
- **并行标注（v4.3）**：Atomize 每任务标「可并行 / 依赖前置 [Txx]」，衔接 Gauntlet 派发。
- **on-task-complete Hook（v4.3）**：任务粒度检查点，校验实质产出 vs 契约、检测「制造干活的假象」、提醒派发后续并行任务。
- **可信度标注**：关键假设 / 设计决策 / 外部依赖 / 选型建议附四行说明（可信度% / 来源 / 盲区 / 建议）；≥80% 正常、60–80% 强制人工确认、<60% 禁止直接输出。
- **记忆系统（v4）**：`.6a-memory/` 每操作一步同步一步；续接任务先读记忆恢复上下文。
- **Gauntlet Loop（v4.1）**：主 Agent 拆解 → 子 Agent 并行执行 → 评委 Agent 盲测验收 → 不达标打回（最多 3 次）→ 全 PASS 后集成终审。见 `project-skeleton/workflows/gauntlet-loop.md`。
- **外部锚点**：每阶段至少触碰 1 类；最终验收须 ≥3 类不同锚点（含 Git 引用完整性锚）。
- **分支保护盾（v3）**：多 Agent 共享分支并行提交时，Worker 守「消失即停」，Lead 用 `tag + reset --soft` 非破坏恢复。见 `project-skeleton/workflows/git-shield.md`。

## Gotchas（模型最易踩的坑，详见 best-practices/gotchas.md）

- 不要把记忆系统当数据库查——它是"每步同步"的工作日志，恢复上下文靠读最近 session，不是 SELECT。
- 可信度标注不要全标 90% 应付门控——标 90% 却来源"逻辑推测"会被判失真打回。
- 单 Agent 角色切换时必须显式声明当前角色，职责边界不可混用。
- Gauntlet Loop 评委是"找茬"不是"夸"——"能用但不专业"就是 REWORK。

## 配套资源

- `6A.md` — 权威协议**总索引**（v4.3，**必须加载**，平台无关）。
- `references/` — 6A 协议**分章文件**（6A-positioning / 6A-constitution / 6A-roles / 6A-gatekeeper / 6A-phases / 6A-loops / 6A-engineering / 6A-git-shield / 6A-memory / 6A-hooks / 6A-gauntlet / 6A-appendix），按需渐进式加载，激活不全量读入。
- `project-skeleton/CONSTITUTION.md` — 项目级共享约束层模板（v4.3 新增），落地时复制到项目根。
- `evals/` — 评测用例集（v4.2 新增，v4.3 增 E007/E008），改前建基线、改后批量回归，覆盖常规/边界/历史失败/高风险输入，以 Constitution 为评判准绳。
- `adapters/` — Claude / Cursor / 通用 system prompt 的即贴片段。
- `project-skeleton/` — ISA 目录范式骨架，落地 6A 时整体复制。
- `project-skeleton/best-practices/` — 工程实践手册（工具使用 / 搜索引用 / 文件操作 / 记忆系统 / Gotchas，v4.3 增 #11–#13）。
- `project-skeleton/scripts/` — 确定性脚本（v4.2 新增）：记忆自检 / 可信度校验 / 引用重置检测 / 反指标计算。
- `project-skeleton/hooks/` — 生命周期 Hook 脚本（v4.2 新增，v4.3 增 on-task-complete）：on-phase-enter/exit / on-gate-fail / on-irreversible-action / on-task-complete。
- `project-skeleton/workflows/gauntlet-loop.md` — **Gauntlet Loop 对抗式并行执行模式**（v4.1 新增）。
- `project-skeleton/workflows/git-shield.md` — 多 Agent 共享分支保护盾。
