# 6A Workflow — 把"模糊需求"变成"可审计交付物"的 Agentic 开发工作流

> 当前版本：**v4.1**（项目级记忆系统 + 工程规范增强 + Gauntlet Loop 并行对抗执行模式）

> 一句话：**6A 给 AI Agent 套上一层"确定性外壳"**——让它像一支纪律严明的工程团队那样，按 `对齐 → 设计 → 拆解 → 审批 → 执行 → 验收` 六步推进，每步都有质量门控、防幻觉校验、持久化记忆和人工关键点。

**六阶段**：`Align（对齐）→ Architect（架构）→ Atomize（原子化）→ Approve（审批）→ Automate（执行）→ Assess（验收）`

> 本 README 面向人讲"何时用 / 主要功能 / 风险 / 边界 / 安装"。完整协议细则（门控清单、嵌套环、锚点规则、Gauntlet Loop 全文）见 **[`6A.md`](./6A.md)** —— 唯一权威来源。

---

## 一、6A 想解决什么问题？

直接把任务丢给 AI，最常见的三种翻车：

1. **"我以为你要…"** —— 需求没对齐就开写，方向从第一步就错了。
2. **一本正经地编造** —— 缺资料时不说"我不知道"，而是虚构 API、伪造数据。
3. **看着完成了，其实是刷分** —— 功能"100% 完成"但塞满 TODO 占位；测试"全过"但断言全是 `assert True`。

6A 的思路不是"让模型更聪明"，而是**在模型外面构建一套工程约束**：把一个大任务强制拆成六个有门控的阶段，每个阶段不通过就打回重做，关键节点必须由人拍板，任何不确定的结论都必须标注可信度——**宁可停下来问，也不许编。**

---

## 二、六个阶段分别做什么

| 阶段 | 名称 | 干什么 | 产物 |
|---|---|---|---|
| **1** | **Align 对齐** | 把模糊需求逼成精确规范 | `ALIGNMENT_*.md`、`CONSENSUS_*.md` |
| **2** | **Architect 架构** | 先设计后编码：架构图、接口契约、数据结构 | `DESIGN_*.md` |
| **3** | **Atomize 原子化** | 拆到"AI 不可能做错"的粒度（≤200 行/任务） | `TASK_*.md` |
| **4** | **Approve 审批** | **人工关键点**：等明确"确认"才动手 | 审批签字 |
| **5** | **Automate 执行** | 按 TASK 逐个实现 + 单测 + 留痕；complex 可走 Gauntlet Loop 并行模式 | 代码 + `ACCEPTANCE_*.md` |
| **6** | **Assess 验收** | 需求覆盖、反指标审计（防刷分）、幻觉自查 | `FINAL_*.md`、`TODO_*.md`、`TRACE_*.md` |

**铁律**：每个阶段结束都要过"质量门控"，不过则循环回退重做。

---

## 三、主要特性

- **四角色 + 评委 Agent**：规划 / 执行 / 评估 / 守门员，职责不可混用；Gauntlet Loop 模式新增独立评委 Agent 做盲测验收。
- **防幻觉可信度标注**：关键假设 / 设计 / 依赖 / 选型必附四行说明（可信度% / 来源 / 盲区 / 建议），按阈值分级处置（≥80% 正常、60–80% 强制人工确认、<60% 禁止输出）。
- **项目级记忆系统（v4）**：`.6a-memory/` 每操作一步同步一步，解决长任务失忆。
- **Gauntlet Loop（v4.1）**：主 Agent 拆解 → 子 Agent 并行执行 → 评委盲测验收 → 不达标打回（最多 3 次）→ 全 PASS 后集成终审。详见 `6A.md` 第九章。
- **外部锚点体系**：每阶段至少触碰 1 类不可篡改锚点（人类判断 / 物理验证 / Git 引用完整性 / 冻结规则 / 数据现实 / 同行评审），最终验收须 ≥3 类。
- **分支保护盾（v3）**：多 Agent 共享分支并行提交时，Worker 守「消失即停」，Lead 用 `tag + reset --soft` 非破坏恢复。
- **Triage 逃逸阀（v4.1）**：trivial / standard / complex 三档，简单任务走精简流程，不为 typo 跑全套六阶段。

> 各特性的完整规则、门控清单、阈值表见 [`6A.md`](./6A.md) 对应章节，本 README 不复述。

---

## 四、风险与边界

- **不替产品做决策**：6A 给建议，最终拍板是人（阶段4）。
- **激活即副作用已设门槛（v4.1）**：standard/complex 任务部署记忆系统前须确认，不再激活即改 `.gitignore`。
- **分支保护盾非万能**：它防"引用被环境挪回"，不防真正的流氓 Agent 强推；Worker 红线须嵌入每个执行 Agent 的 prompt。
- **Gauntlet Loop 有平台要求**：需支持子 Agent 分发；不支持时走单 Agent 串行降级方案（见 6A.md 9.5）。
- **记忆系统不入库**：`.6a-memory/` 默认加入 `.gitignore`，是本地工作记忆；跨任务沉淀走 `knowledge/` 红线库。

---

## 五、安装方式（任选其一）

**A. WorkBuddy**
```bash
git clone https://github.com/bbggl123/6a-workflow.git
cp -r 6a-workflow ~/.workbuddy/skills/6a-workflow
```
对话中输入 `6A 帮我做 xxx` 或 `@6A ...` 即激活。

**B. Claude Code / Codex（CLAUDE.md / AGENTS.md）**
1. 把 `6A.md` 和 `project-skeleton/` 放进你的项目。
2. 将 `adapters/claude.md` 内容追加进项目根的 `CLAUDE.md`（或 `AGENTS.md`）。

**C. Cursor**
1. 把 `6A.md` 和 `project-skeleton/` 放进项目。
2. 将 `adapters/cursor.md` 内容写入 `.cursorrules`（或 `.cursor/rules/6a-workflow.mdc`）。

**D. 任意 LLM / 通用 system prompt**
1. 把 `adapters/generic.md` 整段粘进 Agent 的 system prompt。
2. 确保 Agent 能读到 `6A.md`。

### 安装校验（装完跑一次确认就绪）

```bash
# 1. 权威协议在位
test -f 6A.md && head -1 6A.md
# 2. 接入壳在位
test -f SKILL.md && head -4 SKILL.md
# 3. Gauntlet Loop 工作流在位
test -f project-skeleton/workflows/gauntlet-loop.md && echo "gauntlet-loop OK"
# 4. best-practices 手册齐全
ls project-skeleton/best-practices/{tool-usage,search-citation,file-operations,memory-system,gotchas}.md
# 5. 激活冒烟测试：对 Agent 说 "6A 帮我改一个 typo"，应回复激活语并判定 trivial
```

> 无论哪种方式，真正的"大脑"都是 `6A.md`。适配层只负责告诉 Agent"何时读它、如何激活"。

---

## 六、文件结构

| 文件 / 目录 | 用途 |
|---|---|
| **`6A.md`** | **权威协议**（唯一真相源，v4.1），任何 Agent 加载即运行 6A |
| `SKILL.md` | WorkBuddy 接入壳（指向 `6A.md`） |
| `adapters/` | Claude / Cursor / 通用 system prompt 接入片段 |
| `project-skeleton/` | 在任意项目落地 6A 的 ISA 目录骨架 |
| `project-skeleton/best-practices/` | 工程实践手册（工具/搜索引用/文件/记忆/Gotchas）—— v4.1 起为工程细则唯一真相源 |
| `project-skeleton/workflows/gauntlet-loop.md` | **Gauntlet Loop 对抗式并行执行模式**（v4.1 新增） |
| `project-skeleton/workflows/git-shield.md` | 多 Agent 共享分支保护盾（v3） |
| `project-skeleton/agents/judge.md` | 评委 Agent 角色定义（v4.1 新增） |

---

## 七、许可证

[MIT](./LICENSE) —— **个人 / 教育 / 非商用免费**；**商业使用需事先联系作者获得授权**。
