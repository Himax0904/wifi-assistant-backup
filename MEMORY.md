# Long-Term Memory

## Preferences

### Search
- **Default search tool:** searxng skill (privacy-respecting local metasearch)
- When any web search is needed, prioritize the searxng skill over web_search (Brave API)
- SearXNG instance: configured via `SEARXNG_URL` env var (default: `http://localhost:8080`)

## Notes

- Memory file created: 2026-02-28
- User prefers privacy-focused search tools

## Skills Development

### 2026-03-02: 技能落地与测试

**第一批技能 (已测试)** ✅
1. workflow-automation - 自动化工作流
2. data-visualization - 数据可视化
3. local-rag - 本地 RAG 知识库
- 联动测试通过率：100% (7/7)

**第二批技能 (SKILL.md 完成)** ✅
1. **ssh-remote** - SSH 远程服务器管理
2. **auto-backup** - 自动备份与同步
3. **knowledge-analytics** - 知识与数据分析
- 每个技能包含 🔴🟡🟢 三级安全控制
- 配置文件已创建
- 本地文件：898 行，完整可用

**飞书文档问题复盘** ✅
- 问题：write 操作不写入内容，只有标题
- 解决：使用 append 分块写入
- 复盘文档：https://feishu.cn/docx/ZKZkduTH4onOaqxdf4EcRC2fntg
- 技能沉淀：`skills/feishu-doc-write/SKILL.md`

**下一步**: 等待 MAX 指示是否实现核心引擎。

---

## 角色架构体系 (2026-03-03)

### 六角色分工（NotebookLM 增强版）

| 角色 | 代号 | 核心职责 | 技能目录 |
|------|------|----------|----------|
| 笔杆子 | Writer | 文档撰写、内容编辑、格式输出 | `skills/roles/writer/` |
| 参谋 | Researcher | 信息搜集、调研分析、决策支持 | `skills/roles/researcher/` |
| 运营官 | OPS | 任务管理、流程设计、协调监控 | `skills/roles/ops/` |
| 研发官 | Developer | 代码开发、工具构建、系统集成 | `skills/roles/developer/` |
| 设计师 | Designer | 图片、PPT、视频视觉创作 | `skills/roles/designer/` |
| 知识进化官 | Knowledge Tech | 知识管理 + 技能进化 | `skills/roles/knowledge-tech/` |

**NotebookLM 增强点：**
- Researcher → 结构化输出、引用溯源
- Designer → Slide Deck/Infographic 协作
- Knowledge Tech → NotebookLM 集成与知识库、技能沉淀

### 指挥体系
- **总指挥** — 统筹决策、任务分发、质量把关
- 动态调用对应角色能力
- 保持对 MAX 直接负责

### 应用原则
1. 根据任务类型自动匹配角色
2. 复杂任务可多角色协作
3. 所有输出经总指挥把关
4. 重要操作需 MAX 确认

---

## 双知识库混合架构 (2026-03-03)

**架构设计：** NotebookLM（主动分析）+ 本地知识库（归档存储）+ Git 备份

| 知识库 | 用途 | 存储位置 | Git 备份 |
|--------|------|----------|---------|
| NotebookLM | AI 分析、结构化输出 | Google 云端 | ✅ 导出备份 |
| 本地知识库 | 归档存储、长期保存 | 本地 + 飞书 | ✅ 主备份 + Git |

**目录结构：** `knowledge/`
- `notebooklm-exports/` — NotebookLM 导出内容
- `local-docs/` — 本地文档
- `skills/` — 技能文档
- `templates/` — 模板库
- `SOP.md` — 管理 SOP
- `LOG.md` — 管理日志

**同步机制：** 每周日 20:00 执行同步，Git 提交备份

**迁移能力：** Git 版本控制，支持完整迁移和历史追溯
