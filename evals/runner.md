# evals/runner.md — 如何跑 6A 评测回归（v4.2 新增）

> 课程原则：领域负责人建立自己的评测集，而不是每次优化后凭感觉判断。改前建基线，改后批量回归。

## 目录结构

```
evals/
├── cases.json   # 用例：输入 / 必要文件 / 期望输出 / 评分规则
├── files/       # 配套输入素材（各用例的 fixtures）
└── runner.md    # 本文件：如何跑回归
```

## 跑回归流程

### 1. 建基线（改之前）

在当前（未优化）版本上逐条跑 `cases.json`，记录每个用例的得分，存为 `evals/baseline.json`：

```json
{ "E001": 3, "E002": 2, "E003": 4, "E004": 2, "E005": 2, "E006": 2 }
```

### 2. 跑用例

对每个用例：
1. 准备 `files/` 下对应的 fixture（如需）。
2. 用 `6A <input>` 激活，按期望行为观察。
3. 按 `scoring` 规则打分，记录到 `evals/results-<version>.json`。

可半自动化的判定：
- E006 反指标：直接跑 `bash project-skeleton/scripts/anti-metric.sh <fixture-src>`，看是否告警。
- E002/E005：检查是否产生了对应文件 / 是否出现禁止操作。

### 3. 新旧比对

```bash
# 对比基线与新版本得分（任一用例分数下降即回归）
diff <(jq -S . evals/baseline.json) <(jq -S . evals/results-v4.2.json)
```

任一用例得分下降 → 回归，须修复后再合入。

## 用例覆盖维度

| 维度 | 用例 |
|---|---|
| 常规任务 | E001（trivial 走精简流程）、E007（Constitution 全流程约束，v4.3 新增） |
| 边界情况 | E002（阶段4 未确认不进阶段5）、E006（反指标防刷分）、E008（Clarify 主动提问，v4.3 新增） |
| 历史失败案例 | E004（记忆中断恢复） |
| 高风险输入 | E003（可信度<60% 交人工）、E005（git 引用重置 Worker 应停） |

> **Constitution 作为评判准绳（v4.3 新增）**：所有用例的期望行为均以项目根 `CONSTITUTION.md` 为客观准绳——产出违背 Constitution 即判回归。E007 专门验证 Constitution 的加载与约束生效。每次优化 6A 后，先跑一遍 evals 回归，确认无用例下降，再合入。这是「不凭感觉判断」的工程基线。
