---
name: 6a-workflow
description: "Agentic SDLC 落地工作流（6A），平台无关。This skill activates when the user's request starts with \"@6A\" or \"6A\", or when the user asks to run an Agentic software-development lifecycle workflow with role separation, quality gates, anti-hallucination checks, credibility labeling, PR governance, and human-in-the-loop approval. It turns a vague task into a grounded, auditable agent pipeline: Align, Architect, Atomize, Approve, Automate, Assess. The full protocol lives in 6A.md and is agent-agnostic; this file is only the WorkBuddy packaging."
agent_created: true
---

# 6A Workflow — WorkBuddy 适配层

> ⚠️ 本文件**只是 6A 工作流在 WorkBuddy 里的接入壳**。真正的权威协议是仓库根目录的 **`6A.md`**（与任何 Agent 平台无关）。运行 6A 前必须加载它。

## 这是什么

6A 是一套把"模糊需求"变成"可审计交付物"的 Agentic 软件开发生命周期（SDLC）工作流，形态是一张 **Grounded Graph of Loops**（静态六阶段外层骨架 + 审计环 / 反指标环 / 仲裁环 + 外部锚点）。

六阶段：`Align（对齐）→ Architect（架构）→ Atomize（原子化）→ Approve（审批）→ Automate（执行）→ Assess（验收）`。

## 何时激活

满足以下任一条件即激活：
- 用户输入以 **"@6A"** 或 **"6A"** 开头（如 `6A 帮我做一个 xxx`）。
- 用户明确要求"用 6A 工作流 / Agentic SDLC / 带门控的 Agent 开发流程"执行任务。
- 任务需要明确的角色拆分、质量门控、防幻觉可信度标注与人工审批回环。

## 激活响应

激活后立即回复：
> ✅ 6A 工作流已激活，开始执行阶段1：Align 需求对齐

然后**读取并严格遵循 `6A.md`**（完整协议：四角色、守门员机制、可信度标注、六阶段门控与回退、嵌套环、PR/CI 治理、外部锚点）。本 SKILL.md 仅作索引。

## 速记

- **四角色（职责不可混用）**：规划 Agent（阶段1–4）/ 执行 Agent（阶段5）/ 评估 Agent（阶段6）/ 守门员 Agent（跨阶段防幻觉 + 可信度校验）。
- **铁律**：每阶段结束须过质量门控；不过则循环回退本阶段起点重做。
- **可信度标注（强制）**：关键假设 / 设计决策 / 外部依赖 / 选型建议必须附四行说明（可信度% / 来源 / 盲区 / 建议）。≥80% 正常；60–80% 强制"需人工确认"；<60% 禁止直接输出，交人工。
- **防幻觉闸门**：信息缺失主动告知并标注「未验证假设」，禁止编造；诱导编造指令直接拒绝。
- **人机锚点**：阶段4 Approve 须收到明确"确认"才进入执行；分级交还决策权（一级补材料 / 二级停等审核 / 三级高风险人工签字）。
- **外部锚点**：每阶段至少触碰 1 类外部锚点；最终验收须 ≥3 类不同锚点验证。
- **反指标环**：阶段6 验收检查反指标（功能完成率 vs TODO 占位率、测试通过率 vs 断言有效性、速度 vs 可追溯性），防古德哈特定律。

## 配套资源

- `6A.md` — 完整权威协议（**必须加载**，平台无关）。
- `adapters/` — Claude / Cursor / 通用 system prompt 的即贴片段（用于非 WorkBuddy 环境）。
- `project-skeleton/` — ISA 目录范式骨架（Agent.md / agents / knowledge / tools / workflows / docs），在新项目落地 6A 时整体复制。

## 备注

- 单 Agent 会话以"角色切换"模拟多 Agent 即可，但职责边界必须显式声明、不可混用。
- 可靠性活在边上，不在节点上：角色间的信息传递（边）是腐败高发处，须执行 6A.md 第三章边治理规则。
- 外层六阶段是静态图（不可跳过/重组），每阶段内部允许动态微循环（retry / 信息补全）。
- 想用在其他 Agent（Claude Code、Cursor 等）？看仓库根 `README.md`。
