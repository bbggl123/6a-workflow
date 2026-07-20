# 6A Workflow — Agentic SDLC 落地实例

> **一张 Grounded Graph of Loops**：把"模糊需求"变成"可审计交付物"的 Agentic 软件开发生命周期工作流。
> 规划层 → 执行层 → 评估层，六阶段带质量门控与循环回退，内嵌审计环 / 反指标环 / 仲裁环，并以不可篡改的外部锚点防止系统退化为自洽闭环。

**六阶段**：`Align（对齐）→ Architect（架构）→ Atomize（原子化）→ Approve（审批）→ Automate（执行）→ Assess（验收）`

**四大支柱**：四角色职责分离 · 守门员防幻觉 + 可信度标注 · 分级人机关键点 · PR/CI 治理 + 外部锚点

---

## ⚠️ 这不是某个 Agent 的专属技能

6A 的核心协议 `6A.md` **与平台无关**——它只是一份任何 LLM Agent 都能读懂并遵守的指令文档。
本仓库同时提供：

| 文件 / 目录 | 用途 |
|---|---|
| `6A.md` | **权威协议**（唯一真相源），任何 Agent 加载它即可运行 6A |
| `SKILL.md` | 仅 WorkBuddy 用的接入壳（指向 `6A.md`） |
| `adapters/` | 其他平台的即贴片段：Claude / Cursor / 通用 system prompt |
| `project-skeleton/` | 在任意项目里落地 6A 的 ISA 目录骨架 |

---

## 安装方式（任选其一）

### A. WorkBuddy
克隆仓库，把整个目录放到用户技能目录：
```bash
git clone https://github.com/bbggl123/6a-workflow.git
cp -r 6a-workflow ~/.workbuddy/skills/6a-workflow
```
对话中输入 `6A 帮我做 xxx` 或 `@6A ...` 即激活。

### B. Claude Code / Codex（AGENTS.md / CLAUDE.md）
1. 把本仓库根目录的 `6A.md` 和 `project-skeleton/` 放进你的项目。
2. 将 `adapters/claude.md` 的内容追加进项目根的 `CLAUDE.md`（或 `AGENTS.md`）。
3. 在 Claude 里说 `6A 帮我做 xxx` 即可。

### C. Cursor
1. 把 `6A.md` 和 `project-skeleton/` 放进项目。
2. 将 `adapters/cursor.md` 内容写入项目根 `.cursorrules`（或 `.cursor/rules/6a-workflow.mdc`）。

### D. 任意 LLM / 通用 system prompt
1. 把 `adapters/generic.md` 整段粘进 Agent 的 system prompt。
2. 确保 Agent 能读到 `6A.md`（放在其可访问的工作区或知识库里）。
3. 触发词 `@6A` / `6A` 即可启动。

> 无论哪种方式，真正的"大脑"都是 `6A.md`。适配层只负责告诉 Agent"何时读它、如何激活"。

---

## 在项目中落地（project-skeleton）

把 `project-skeleton/` 整体复制到你的项目根，即获得一套 6A 运行骨架：

```
your-project/
├─ Agent.md              # 路由：识别 @6A 前缀、区分阶段、选择执行角色
├─ readme.md            # 执行边界、完成证据、巡视与维护规则
├─ agents/              # 四角色描述：职责、必读文档、约束、输出
├─ best-practices/      # 各角色范例与反例
├─ knowledge/           # 共享状态（红线库 / 反模式 / 成功模式 / 纠正记录）
├─ tools/               # 各角色可用/禁用工具集与约束
├─ workflows/           # 六阶段流程、嵌套环、外部锚点
└─ docs/任务名/         # 本次任务的 ALIGNMENT/CONSENSUS/DESIGN/TASK/ACCEPTANCE/FINAL/TODO/TRACE
```

---

## 许可证

[MIT](./LICENSE) —— **个人 / 教育 / 非商用免费**；
**商业使用需事先联系作者获得授权**（见 LICENSE 文件中的 Commercial Use 条款）。

---

## 参考来源

- Rahul (@sairahul1) 的五层 AI 系统架构（Prompt→Context→Harness→Loop→Graph）
- Sydney Runkle & Yuvraj Singh：Static Graph + Dynamic Inner Loop
- Carlos E. Perez：Graph of Loops、单 Loop 的四大致命缺陷（Goodhart / 向上盲区 / 结构冲突 / 测量衰退）
- 外部锚点（Grounding Anchors）与 Shared State 思想
