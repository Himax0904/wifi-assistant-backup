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
