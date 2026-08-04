# 7.8：多 Agent 共享分支保护盾（Git Branch-Reset Shield · v3 全新章节）

> 本文件是 6A 权威协议的分章加载单元。仅在阶段5 启用多 Agent 共享分支并行提交时加载。

> **适用场景**：阶段5 用 Agent 工具派生多个 `implementation-engineer` 队友、或 TeamCreate + 队友，在**同一条共享 git 分支**上并行提交时。这是执行层针对"提交神秘消失 / HEAD 被外部回退"这一具体失败模式的专属防退化机制。完整操作手册见 `project-skeleton/workflows/git-shield.md`。

## 7.8.1 问题现象与根因

- **现象**：某 Agent 报告"完成"后，`git rev-parse HEAD` / `git log` 显示分支指向了**更早的提交**，而 `git status` 干净、或只有预期暂存变更；或 Worker 报告"我的提交消失了 / HEAD 被无故改动"。
- **鉴别**：`git cat-file -t <lost_hash>` 仍返回 `commit`，且 `git diff --cached <lost_hash>` / `git diff <lost_hash>` 为空（工作树与丢失提交完全一致）。
- **根因**：在 Agent 沙箱中，每个 Agent 的"完成"通知都可能触发一次外部 `git update-ref`，把活动分支引用**移回基线提交**。它**保留 index 与工作树，只挪动引用；提交对象从不被删除**。这**不是数据丢失，也不是流氓 Agent**（除非同时出现 `_v2_*` / `*.bundle` 等垃圾目录）。

> 引用是否被重置可由确定性脚本检测：`scripts/ref-reset-detect.sh` 比对 git reflog，无需纯靠 Worker 行为约束。

## 7.8.2 Lead 非破坏性恢复流程（权威 SOP）

1. **先验证，不要慌**：`git rev-parse HEAD` / `git status --short` / `git cat-file -t <lost_hash>`（须返回 commit）/ `git diff <lost_hash> --stat`（须为空）/ `git log --oneline <lost_hash> -6`（确认链完整、父提交即基线）。
2. **用 tag 锚定（非破坏）**：`git tag -f <stable-tag> <lost_hash>`。Tag 不受引用移动影响。
3. **推回指针（非破坏）**：`git reset --soft <stable-tag>`——移动 HEAD/分支到后代提交，**index 与工作树原封不动（零代码丢失）**。仅在丢失提交是当前 HEAD 直接后代（fast-forward）时使用；分支被 worktree 占用导致 `branch -f` 被拒时，`reset --soft` 才是正确工具。
4. **重跑测试证明完整性**：`python -m pytest tests/ -q`（或项目测试套件），全绿再宣告恢复。
5. **串行化恢复**：只有在所有 Worker 停止后再恢复，避免反复重置互相打架。

## 7.8.3 Worker 防御红线（嵌入每个执行 Agent 的 prompt）

- **绝不** `git reset --hard`、`git push -f`、`git branch -D/-f`、`git checkout -- .`、`git clean -f`。
- **绝不**创建 `.bundle` 或 `_v2_*` / `_verify_*` / `_ft*` / `.git` 拷贝等垃圾文件；正常提交 `git add <files>` + `git commit -m "Txx: ..."`。
- **上下文安全**：不把完整 TASK/DESIGN 读入上下文，只读所需源文件或行区间。
- **消失即停（Stop-on-disappearance）**：提交后若提交消失、HEAD 被外部改动、或刚写文件被删——**立即停止**，不重建历史、不强推、不重试对抗，向 Lead 报告确切现象。**这条规则是防止困惑 Worker 搞坏仓库的关键。**

## 7.8.4 反模式（禁止）

- ❌ `git reset --hard <baseline>` 去"恢复"——丢弃更新提交工作树且方向搞反。
- ❌ 把引用移动当流氓 Agent，开始强推 / 重写历史。
- ❌ 把巨大设计文档整篇读进 Worker 上下文，引发上下文溢出（最初看起来像"仓库损坏"）。

> **图工程视角**：7.8 是「恢复环（Recovery Loop）」——仲裁环的特化。它把"引用完整性"确立为一类**不可被 AI 自述篡改的外部锚点**（内容寻址哈希由 Git 对象库保证），从而在多 Agent 边治理中堵住"提交在边上蒸发"这一最隐蔽的腐败源。
