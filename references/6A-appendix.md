# 附录：6A 与图工程核心概念对照速查表

> 本文件是 6A 权威协议的分章加载单元。需要快速对照概念时加载。

| 图工程概念 | 6A 落地 | 出处 |
|---|---|---|
| 模型商品化 | 6A 不绑定任何模型，可换 LLM | Rahul 五层架构 |
| Harness（确定性外壳） | 第四章守门员机制 + 第七章安全规范 | Harness Engineering |
| Loop 停止信号 | 质量门控 + 跳出条件 + 无进展检测 | Loop Engineering |
| 独立 Checker | 评估 Agent ≠ 执行 Agent（角色分离） | Loop Engineering 核心原则 |
| Static Graph（合规边界） | 六阶段主流程不可跳过不可重组 | Sydney Runkle / Yuvraj Singh |
| Dynamic Inner Loop | 阶段5 内的五步微循环 + retry | 同上 |
| Graph of Loops | 第六章嵌套环结构 | Carlos E. Perez 二阶控制论 |
| PAIR 环（优化盯审计） | 优化环 + 审计环互相监督 | Graph Engineering 图解 |
| HIERARCHY 环（慢设目标快执行） | 阶段4 设目标 → 阶段5 快执行 | 同上 |
| ARBITRATE 环（权衡裁决） | 阶段4 分级交还 + 预算审查 | 同上 |
| Goodhart 防护 | 阶段6 反指标检查（Anti-Goodhart Audit） | Carlos E. Perez 单 Loop 致命缺陷 |
| 向上盲区防护 | 阶段4 人工审批（元环） | 同上 |
| 结构冲突防护 | 仲裁环 + 三级制决策权交还 | 同上 |
| 测量衰退防护 | 审计环 + 留痕完整性强制校验 | 同上 |
| Grounding Anchors | 第七章外部锚点体系（6 类锚点，含 Git 引用完整性） | lucas / Kurt 终局结论 |
| 分支引用完整性锚（v3） | 7.8 分支保护盾 + 恢复环 | git-branch-reset-shield 实战沉淀 |
| Gauntlet Loop（v4.1） | 第九章对抗式并行执行：主 Agent 拆解 → 子 Agent 并行 → 评委盲测验收 → 打回循环 | Opus 5 Gauntlet Loop 复刻沉淀 |
| Shared State | knowledge/ 红线库作为跨角色共享记忆 | Unwind AI Operating Graph |
| Reliability lives in EDGES | 第三章边治理规则 | 图工程核心洞见 |
| 可审计可追责 | 全程 TRACE + LOG 编号 | SDLC 最佳实践 + 图工程审计环 |
