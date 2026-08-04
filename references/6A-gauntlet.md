# 第九章：Gauntlet Loop 对抗式并行执行模式（v4.1 新增）

> 本文件是 6A 权威协议的分章加载单元。仅在 complex 任务、模块边界清晰且平台支持子 Agent 分发时加载。完整可复用协议见 `project-skeleton/workflows/gauntlet-loop.md`。

## 9.1 什么时候用 Gauntlet Loop

当任务满足以下条件时，规划 Agent 在阶段3 Atomize 后可选用 Gauntlet Loop 模式执行阶段5：

- 任务可拆成**模块边界清晰、接口可独立定义**的并行子任务（Group A/B/C 分组）。
- 运行平台**支持子 Agent 分发**（多 Agent / 多会话）；不支持时走 9.5 降级方案。
- 任务规模为 **complex**（triage 判定）；standard / trivial 不启用，避免过度设计。

> Gauntlet Loop 是阶段5 的**并行变体**，不取代六阶段骨架——阶段1–4 仍走 Align/Architect/Atomize/Approve，阶段6 仍走 Assess；它替换的是阶段5"串行逐任务执行"为"并行执行 + 独立评委盲测"。

## 9.2 三段式结构

| Stage | 角色 | 职责 |
|---|---|---|
| **Stage 1 拆解 & 编排** | 规划 Agent（主 Agent） | 把任务拆成可并行独立模块（M1/M2…），每个模块给：编号、名称、核心职责、输入输出契约、依赖关系、≤5 条验收标准；按依赖分 Group A/B/C |
| **Stage 2 并行执行** | 执行 Agent × N（子 Agent） | 每个子 Agent 只负责自己的模块：先输出 ≤5 步实现计划，再写完整可运行代码（无 TODO/占位符），严格遵循技术栈与接口契约，不修改其他模块、不引入全局命名冲突，最后自验收 |
| **Stage 3 盲测验收** | 评委 Agent | 极其苛刻地逐项验收：功能完整性 / 代码质量 / 架构合理性；评分 PASS / REWORK / FAIL；只看交付物，不看子 Agent 自验收 |

## 9.3 循环控制

1. 主 Agent 拆解 → 阶段4 Approve 确认 → 子 Agent 并行执行。
2. 每个子 Agent 完成后，评委 Agent 盲测验收：
   - **PASS** → 合并到最终交付物。
   - **REWORK**（通过 ≥80%）→ 打回对应子 Agent，附精确到模块/行号的问题清单 + 改进建议，**最多 3 次**。
   - **FAIL**（通过 <80%）→ 退回主 Agent 重新拆解该模块。
3. 所有模块 PASS 后，主 Agent 负责最终集成。
4. 集成后再由评委 Agent 做整体终审（接口一致、数据流转、命名冲突、循环依赖）。
5. 终审 PASS → 交付；终审 REWORK → 打回相应模块。

**循环终止条件**：全部模块 PASS + 整体终审通过 = 停止；同一模块连续 3 次 REWORK 未通过 = 主 Agent 介入重拆或降级方案；总迭代 >10 次 = 人工介入决策。

## 9.4 与 6A 既有机制的融合（关键）

Gauntlet Loop 不是裸跑的"并行 + 验收"，它必须叠加 6A 的全部约束：

| 6A 机制 | 在 Gauntlet Loop 中的落点 |
|---|---|
| **守门员可信度标注** | 子 Agent 实现中涉及外部依赖/未验证库版本/性能预估时，仍附四行可信度说明（见 `references/6A-gatekeeper.md` 4.2）；评委验收时把"可信度标注缺失"计入不通过项 |
| **外部锚点** | 评委验收的"物理验证锚点"= `exit 0`/编译通过/测试全绿；"Git 引用完整性锚"= 并行提交后校验 HEAD（可调 `scripts/ref-reset-detect.sh`）；禁止仅凭子 Agent 自述 PASS |
| **反指标环** | 评委须查反指标（可调 `scripts/anti-metric.sh`）：功能 100% 但 TODO>0、测试全过但空断言>0、接口文档与实际不符——计入 REWORK |
| **分支保护盾** | 多子 Agent 在共享分支并行提交时，Worker 守「消失即停」，Lead 用 `tag + reset --soft` 非破坏恢复（见 `references/6A-git-shield.md`） |
| **记忆系统** | 并行执行期间每个子 Agent 的 `[MODIFY]/[RUN]/[ERROR]` 仍每步同步到 `.6a-memory/session/`；评委的 REWORK/FAIL 裁决记录为 `[FIND]` |
| **人机锚点** | 阶段4 Approve 仍是必经人工关卡；FAIL 退回重拆、超 10 次迭代，都须人工介入 |

## 9.5 降级方案（平台不支持子 Agent 分发时）

单 Agent 迭代模式：主 Agent 拆解后**逐个串行执行模块**（M1→M2→…），每完成一个模块用评委提示词自检，不通过就原地改进、通过再进下一个；全部完成后用评委提示词做整体终审。思维一致，只是把并行降级为串行。

## 9.6 指令

- `/loop`：重新执行最近一次未通过的验收流程，不跳过任何环节，每次循环须有明确改进方向。
- `/rerun <module_id>`：只重新执行指定模块，其他已 PASS 模块不受影响。
