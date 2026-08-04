# Agent.md — 6A 路由入口

本文件是 6A 工作流在**本项目**中的路由与角色调度中心。

## 激活条件
- 用户输入以 `@6A` 或 `6A` 开头时激活。
- 激活后回复：`✅ 6A 工作流已激活，开始执行阶段1：Align 需求对齐`

## 激活后第一步：Triage（v4.1）

激活后先判任务规模（见 6A.md 2.1）：
- **trivial**（typo / 单行 bugfix / 纯格式）→ 精简流程：跳过记忆系统、跳过逐条可信度标注，阶段1–4 压缩为口头确认。拿不准就升级到 standard。
- **standard** → 完整 6A，记忆系统可选。
- **complex**（多模块 / 架构级 / 多 Agent 并行）→ 完整 6A + 记忆系统 + 可选 Gauntlet Loop。

## 激活后第二步：确认门槛 + 记忆系统（v4.1）

standard / complex 任务部署记忆系统前须先向用户确认：
> 即将在项目根部署 `.6a-memory/` 记忆目录并修改 `.gitignore`，确认开始？

收到确认后：
1. 检查项目根是否存在 `.6a-memory/` 目录
2. 若不存在：创建完整目录结构并初始化（参考 `best-practices/memory-system.md`）
3. 若存在：读取 `INDEX.md` → `progress/current-phase.md` → 最近 session 日志，恢复上下文
4. 在 session 日志中记录 `[CHECKPOINT] 6A 工作流激活`
5. 确认 `.6a-memory/` 已在 `.gitignore` 中

> 完整记忆系统规范见 `6A.md` 第7.9节与 `best-practices/memory-system.md`。

## 阶段 → 角色映射
| 阶段 | 负责角色 | 核心产物 | 记忆同步要求 |
|---|---|---|---|
| 1 Align | 规划 Agent | CLARIFY / ALIGNMENT / CONSENSUS | 项目画像写入 `context/`，决策写入 `decisions/`，Constitution 已加载 |
| 2 Architect | 规划 Agent | DESIGN | 架构决策写入 `decisions/DECS-*` |
| 3 Atomize | 规划 Agent | TASK | 任务清单同步到 `progress/` |
| 4 Approve | 规划 Agent + 人工 | 审批签字（HITL 锚点） | 审批结果记录 `[APPROVE]` |
| 5 Automate | 执行 Agent | 代码 + ACCEPTANCE | 每步Inner Loop同步记忆（见 `references/6A-phases.md` 阶段5） |
| 6 Assess | 评估 Agent | FINAL / TODO / TRACE | 经验沉淀到 `lessons/`，最终同步到 `knowledge/` |

## 调度规则
- 守门员 Agent 跨阶段常驻，任何阶段可信度标注缺失/失真 → 直接判不合格。
- 守门员额外检查：记忆系统同步完整性（每阶段门控必查项）。
- 每阶段过质量门控方可进入下一阶段；不过则循环回退本阶段起点。
- **每操作一步同步一步记忆**：读取、决策、修改、运行命令、遇到错误——每个关键动作立即写入 session 日志。
- **上下文恢复优先读记忆**：不确定之前做了什么时，先读 `.6a-memory/` 而非凭记忆猜测。
- **多 Agent 阶段5**：多个执行 Agent 在同一 git 分支并行提交时，启用 `workflows/git-shield.md` 保护盾（Worker 守「消失即停」，Lead 用 tag + reset --soft 非破坏恢复）。
- **Gauntlet Loop 模式（v4.1）**：complex 任务、模块边界清晰且平台支持子 Agent 分发时，阶段5 可启用 `workflows/gauntlet-loop.md`——主 Agent 拆解 → 子 Agent 并行 → 评委 Agent（`agents/judge.md`）盲测验收 → 不达标打回（最多 3 次）→ 全 PASS 后集成终审。阶段4 Approve 仍是必经人工关卡。
- **确定性脚本（v4.2）**：记忆完整性 / 可信度校验 / 引用重置检测 / 反指标计算由 `scripts/` 脚本承载，各节点先跑脚本拿事实再判断；**生命周期 Hook**（`hooks/`）在阶段进入/退出/门控失败/不可逆操作/**单任务完成**时自动触发固定动作，详见 `references/6A-hooks.md`。
- **Constitution 共享约束层（v4.3）**：项目根 `CONSTITUTION.md` 是安全红线/代码质量/测试策略/Gotchas 的单一冻结约束源，Align 前必读，所有阶段产出门控校验是否违背，evals 评判准绳。
- **Clarify 主动提问（v4.3）**：Align 内 AI 主动产出 CLARIFY 提问清单，可信度 <80% 的项必进清单，未决项不靠猜推进（标风险或转阶段4 拍板）。
- **WHAT-only 门控（v4.3）**：Align 产出物（含输出契约）禁止含实现技术选型，技术栈留到 Architect。
- **并行标注（v4.3）**：Atomize 每任务标「可并行 / 依赖前置 [Txx]」；标注「可并行」不等于自动并行，须主 Agent 显式派发（见 Gotchas #12）。
- **on-task-complete Hook（v4.3）**：阶段5 单任务完成时触发，校验实质产出 vs 契约、progress 勾选、检测「制造干活的假象」、提醒派发后续并行任务。
- **智能小队协作模式（v4.4）**：standard/complex 任务在阶段3 Atomize 拆解后，队长为每个任务/任务组按 `references/6A-squad.md` 决策树选择 8 种协作模式之一（① 路由 ② 专家会诊 ③ 圆桌讨论 ④ 并行 ⑤ 投票 ⑥ 接力 ⑦ 生产评审 ⑧ 红蓝对抗），记录在 TASK 文档「协作模式」列，阶段5 前按 `workflows/squad-modes.md` 模板派发。同一任务不同阶段可切换模式。平台不支持子 Agent 分发时按 10.6 降级。Gauntlet Loop 仍是 complex 任务并行+评审的推荐预设组合。
- **两种专家协作（v4.2）**：6A 落地需 AI 工程师 + 领域专家协作，领域判断标准不能靠推测，须通过访谈和真实样例补齐 knowledge 红线库。
- 完整协议见仓库根 `6A.md`（索引壳）与 `references/` 分章文件，以及本项目 `workflows/main-pipeline.md`、`workflows/git-shield.md`、`workflows/gauntlet-loop.md`、`workflows/squad-modes.md`。
