# workflows/loops.md — 嵌套环结构（Graph of Loops）

> 6A 不是一条直线，而是一张 Graph of Loops。单一优化环会自发学会"刷分"，须用环盯环防止退化。

## 环拓扑
```
元环(Meta) 阶段4 人工审批锚点 ──设目标/否决──► 优化环(Optimizing) 阶段1→2→3→5→6
                                                │
                          ┌─────────────────────┼─────────────────────┐
                          ▼                     ▼                     ▼
                     审计环(Audit)          反指标环(Counter)        仲裁环(Arbitrate)
                     阶段6 幻觉自查+留痕     阶段6 古德哈特防护       阶段4 分级交还+预算审查
```

## 各环职能与防退化
| 环 | 位置 | 防的缺陷 |
|---|---|---|
| 优化环（快） | 阶段1→2→3→5→6 | —（动力源） |
| 审计环（慢） | 阶段6 幻觉自查 + 留痕审计 | 测量衰退（nobody watches the watcher） |
| 反指标环 | 阶段6 Anti-Goodhart 检查 | 古德哈特定律（metric gets gamed） |
| 仲裁环 | 阶段4 分级交还 + 阶段5 预算审查 | 结构冲突（loops fight each other） |
| 元环 | 阶段4 人工审批 + 外部锚点 | 向上盲区（can't ask if target is right） |

## 动态重构钩子（静态骨架内允许）
- 单任务连续失败 ≥3 次 → 降级：简化 scope 或换方案（记 TRACE，通知人工）。
- Token/时间超预算 80% → 坍缩：合并小任务 / 降低模型规格（须经阶段4 二级确认）。
- 发现新依赖/风险 → 分支：暂停，插入调研子任务（同样走 Align→Architect 微流程）。
- 人工中途改需求 → 重路由：回阶段1，保留已完成的增量产出。

## 恢复环（Recovery Loop · 多 Agent 共享分支专用 · 见 `workflows/git-shield.md`）
> 当阶段5 多个 Worker 在同一分支并行提交，而执行环境把分支引用悄悄挪回旧基线时触发。它是仲裁环的一个特化：先停、再锚、后恢复。

- **触发**：Worker 报告"提交消失 / HEAD 被外部改动"，且 `git cat-file -t <hash>` 仍返回 commit、`git diff <hash> --stat` 为空。
- **动作（Lead 串行执行）**：① 让所有 Worker 停止 → ② `git tag -f <tag> <lost_hash>` 锚定 → ③ `git reset --soft <tag>` 非破坏推回 → ④ 重跑测试全绿。
- **防的缺陷**：把环境行为误判为数据丢失或流氓 Agent，进而 `reset --hard` / 强推导致真正的代码丢失。
- **约束**：恢复期间禁止任何 Worker 写操作，避免多次重置互相打架。
