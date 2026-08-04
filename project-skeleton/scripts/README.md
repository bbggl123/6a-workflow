# scripts/ — 确定性优先交给代码（v4.2 新增）

> 课程原则：计算、格式转换、校验与批处理使用脚本并补测试，避免模型用 Token 慢慢算还漂移。6A 把本该是代码的事固化成脚本，模型纪律降为兜底。

## 脚本清单

| 脚本 | 作用 | 何时调用 |
|---|---|---|
| `memory-audit.sh` | 扫 `.6a-memory/` 时间戳连续性 + 关键动作覆盖，输出缺口报告 | 每阶段质量门控时（守门员调用） |
| `credibility-lint.sh` | 校验产出中可信度标注四行完整性 + 百分比区间合法性 + 数值来源矛盾 | 阶段1–3 产出文档门控、PR CI 门禁 |
| `ref-reset-detect.sh` | git reflog 比对，检测活动引用是否被环境挪回更早提交 | 阶段5 多 Agent 共享分支并行提交后、评委验收前 |
| `anti-metric.sh` | 计算反指标：TODO 占位率、空断言率、硬编码凭据数 | 阶段6 反指标检查（Anti-Goodhart Audit） |

## 用法

```bash
bash scripts/memory-audit.sh .                         # 记忆完整性自检
bash scripts/credibility-lint.sh docs/任务名/          # 可信度标注校验
bash scripts/ref-reset-detect.sh . feature-branch      # 引用重置检测
bash scripts/anti-metric.sh src/ tests/                # 反指标计算
```

所有脚本退出码：`0` 通过、`1` 有问题需处理、`2` 前置不满足（如目录不存在）可跳过。

> 脚本是确定性保证，模型在对应节点**先跑脚本拿事实，再做判断**；不得跳过脚本纯靠口头检查。
