# workflows/git-shield.md — 多 Agent 共享分支引用保护盾（Git Branch-Reset Shield）

> **定位**：这是 6A 阶段5（Automate 执行层）在**多 Agent 共享同一 git 分支**时的专属防退化机制，也是「物理验证锚点」下新增的 **Git 引用完整性锚点**。它保证：即使执行环境把分支引用悄悄挪回旧基线，也**不丢一行代码、不改错方向**。
>
> **何时启用**：当你用 Agent 工具派生多个 `implementation-engineer` 队友，或用 TeamCreate + 队友，在**同一条共享分支**上并行提交时启用。单 Agent 顺序提交场景可不启用，但 Worker 防御红线仍建议常驻。

---

## 一、问题现象（何时判定命中本盾）

在多 Agent 沙箱里同分支协作时，出现以下任一现象即命中：

- 某 Agent 报告"已完成"后，`git rev-parse HEAD` / `git log` 显示分支指向了**更早的提交**（例如某个 T13 基线），而 `git status` 是干净的、或只有预期内的暂存变更。
- Worker 报告"我的提交消失了" / "HEAD 在我没操作的情况下被改动"。
- `git cat-file -t <hash>` 仍能找到那个"丢失"的提交，且 `git diff --cached <hash>` / `git diff <hash>` 为空（工作树与丢失的提交**完全一致**）。

> **关键鉴别**：这**不是数据丢失，也不是流氓 Agent**——除非你同时看到 `_v2_*` / `_verify_*` / `*.bundle` 等垃圾目录。它是**执行环境在重定位分支引用**。

---

## 二、根因（已观测）

在 Agent 沙箱中，每个 Agent 的"完成"通知都可能触发一次外部 `git update-ref`（或等价操作），把当前活动分支引用**移回某个基线提交**。该操作**保留 index 与工作树**，只挪动引用；**提交对象从不被删除**。表现为：一个刚创建的提交突然不再是 HEAD；reflog 显示一条 HEAD 后退记录，但 Worker 并没有执行任何 reset。

---

## 三、Lead 恢复流程（非破坏性 · 权威 SOP）

> 由 **协调者 / 守门员 Agent** 执行。执行前**必须先让所有 Worker 停止**，避免多次重置与恢复互相打架（见"五、串行化恢复"）。

1. **先验证，不要慌。** 在仓库根依次运行：
   - `git rev-parse HEAD` 与 `git branch --show-current` —— 记录当前（被重置的）HEAD 与分支。
   - `git status --short` —— 预期为干净，或仅为真实的暂存变更。
   - `git cat-file -t <lost_hash>` —— 必须返回 `commit`。
   - `git diff --cached <lost_hash> --stat` 与 `git diff <lost_hash> --stat` —— 预期为**空**（工作树/index 与丢失提交一致）。
   - `git log --oneline <lost_hash> -6` —— 确认提交链完整，且其父提交就是被重置到的基线。
2. **用 tag 锚定（非破坏）。** `git tag -f <stable-tag> <lost_hash>`（如 `persona-phase5`）。Tag 不受引用移动影响，提供稳定引用。
3. **把指针推回去（非破坏）。** `git reset --soft <stable-tag>` —— 将 HEAD/分支移到后代提交，**index 与工作树原封不动（零代码丢失）**。仅在丢失提交是当前 HEAD 的**直接后代**（fast-forward 情形）时使用。若分支被某个 worktree 占用，`git branch -f <branch> <tag>` 可能被拒（"used by worktree"）—— 此时 `reset --soft` 才是正确工具。
4. **重跑测试证明完整性。** `python -m pytest tests/ -q`（或项目对应测试套件）。确认全绿再宣告恢复完成。
5. **串行化恢复。** 只有在所有 Worker 都停止后再恢复指针，避免反复重置。

---

## 四、Worker 防御红线（须嵌入每个执行 Agent 的 prompt）

- **绝不**运行 `git reset --hard`、`git push -f`、`git branch -D/-f`、`git checkout -- .`、`git clean -f`。
- **绝不**创建 `.bundle` 文件或 `_v2_*` / `_verify_*` / `_ft*` / `_clone_test*` / `_bundle_clone*` / `commit_err.txt` / `.git` 拷贝。正常提交即可：`git add <files>` + `git commit -m "Txx: ..."`。
- **上下文安全**：不要把完整的 TASK / DESIGN markdown 读入上下文（会撑爆上下文窗口）；只读需要的具体源文件或具体行区间。
- **消失即停（Stop-on-disappearance）**：如果提交后提交消失、HEAD 被外部改动、或刚写的文件被删除——**立即停止**。不要重建历史、不要强推、不要重试对抗。向 Lead 报告**你观察到的确切现象**。由 Lead 用 tag + reset --soft 恢复。**这条规则是防止困惑的 Worker 把仓库搞坏的关键。**

---

## 五、反模式（禁止）

- ❌ 用 `git reset --hard <baseline>` 去"恢复"——这会丢弃更新提交的工作树，且方向搞反。
- ❌ 把引用移动当成流氓 Agent，开始强推 / 重写历史——它是环境行为，不是攻击者。
- ❌ 把巨大的设计文档整篇读进 Worker 上下文——会引发上下文溢出失败，最初看起来就像"仓库损坏"。
- ❌ 多个 Worker 未停止就抢着恢复——重置会互相打架。

---

## 六、验证（恢复完成判定）

恢复后：`git status` 干净、`git rev-parse HEAD` 等于锚定的 tag、测试套件全绿。原始提交对象仍可经 tag 与 reflog 到达。

---

## 七、与 6A 的挂接关系

| 6A 结构 | 本盾的挂接 |
|---|---|
| 阶段5 Automate（执行层） | Worker 防御红线常驻；提交流程收敛为 `git add + git commit` |
| 边治理：执行 → 执行（并行 Worker） | 「消失即停」防止边上的引用腐败扩散 |
| 边治理：执行 → 评估 | PR + CI 前先确认引用完整性（HEAD == 预期后代） |
| 物理验证锚点（第七章.7） | 新增 **Git 引用完整性锚点**：以 `cat-file` / `diff --stat` 客观校验，不依赖 AI 自述 |
| 仲裁环 / 恢复动作 | Lead 串行化恢复即一次仲裁：先停 Worker，再 tag+reset --soft |
| knowledge/anti-patterns.md | 收录「引用重置误判为数据丢失」「Worker 对抗式强推」两个反模式 |
