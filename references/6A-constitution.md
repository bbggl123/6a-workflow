# Constitution 层 —— 共享约束源（v4.3 新增）

> 本文件是 6A 权威协议的分章加载单元。理解「宪法/约束层」机制时加载。

## 为什么需要 Constitution

Spec Kit 方法论的核心之一是 **constitution（宪法）**：把安全红线、代码质量要求、测试策略、合规约束等「不可商量的规矩」**一次写好，全流程共享引用**，而不是散落在各阶段、靠模型每次自觉回忆。

6A v4.2 之前，这些约束分散在三处：
- `knowledge/red-lines.md`（硬性红线）
- `best-practices/gotchas.md`（高信号坑）
- `references/6A-engineering.md` 7.1–7.7（防幻觉 / 安全 / PR 治理 / 测试）

三处并存导致两个问题：① 改一处忘另一处 → 内容漂移；② 模型在某个阶段执行时，未必记得去翻另外两处。Constitution 层把它们**固化为单一 `CONSTITUTION.md`**，所有阶段、所有角色共享同一份约束源。

## Constitution 是什么

`CONSTITUTION.md` 是项目级的**单一共享约束层**，落地于项目根（与 `Agent.md` 同级）。它不是阶段产物，而是**全流程冻结规则锚点**——在 Align 之前就已存在，所有阶段产出必须对齐它，不得违背。

Constitution 包含四块：

| 块 | 内容 | 来源（v4.3 前的散落位置） |
|---|---|---|
| 安全红线 | 密钥管理、防注入、日志脱敏、不可逆操作门槛 | `knowledge/red-lines.md` 安全红线 + `6A-engineering.md` 7.2 |
| 代码质量 | 命名/风格/复用/简洁/注释规范、禁止 TODO 占位掩盖 | `6A-engineering.md` 7.1 + `gotchas.md` #7 |
| 测试策略 | 单元/边界/异常覆盖、反指标（TODO 占位率、断言有效性）、互确认警报 | `6A-engineering.md` 7.4 + `gotchas.md` #6 |
| 高信号坑（摘要） | 模型最易踩的 10+ 条，每条一行锚点 | `best-practices/gotchas.md` |

> Constitution 是**摘要 + 锚点**：每条约束附「详见 xxx.md」指向完整原文。它不取代 best-practices / knowledge 的详文，而是提供「一次读全、全流程共享」的单一入口。详文仍是各自文件，Constitution 是它们的统一索引与冻结快照。

## 何时加载

| 时机 | 动作 |
|---|---|
| Align 阶段开始前（阶段1 步骤0） | 读取 `CONSTITUTION.md`，作为后续所有产出的约束基线 |
| 任一阶段产出前 | 校验产出是否违背 Constitution（门控项） |
| evals 评测时 | Constitution 作为**评判依据**——用例的期望输出以 Constitution 为客观准绳（见 `evals/runner.md`） |
| Constitution 本身变更 | 视为冻结规则变更，须人工确认（与阶段4 同级门槛），并同步更新 best-practices / knowledge 详文 |

## 与既有机制的关系

- **Constitution ≠ red-lines.md 的重复**：red-lines.md 是 knowledge/ 下的共享状态库，Constitution 是它的**冻结快照 + 跨块统一入口**。red-lines.md 可随任务追加新红线，Constitution 的变更须走人工确认门槛（防止单次任务悄悄改规矩）。
- **Constitution 是 Static Graph 的冻结规则锚点**：与 `references/6A-loops.md` 的「冻结规则锚点」机制一致——动态环不可篡改 Constitution。
- **Constitution 与自由度档位联动**：低自由度步骤（删除/迁移/部署）必须显式对照 Constitution 的安全红线与不可逆操作门槛。
- **Constitution 与 evals 联动**：评测用例的期望行为以 Constitution 为准绳；优化 6A 后跑回归， constitution 违背即回归。

## 项目级 Constitution 模板

见 `project-skeleton/CONSTITUTION.md`。落地 6A 时复制到项目根，按项目实际填充/裁剪。
