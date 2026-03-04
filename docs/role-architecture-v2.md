# 角色架构体系 v2.0（NotebookLM 增强版）

**更新日期：** 2026-03-03  
**版本：** v2.0  
**状态：** 已部署

---

## 架构图

```
                    ┌─────────────────┐
                    │   总指挥 无牙   │
                    │  (统筹决策/把关) │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│   内容侧      │   │   执行侧      │   │   支撑侧      │
│               │   │               │   │               │
│ 🖋️ Writer    │   │ 🔧 Developer  │   │ 📊 OPS        │
│ 🧠 Researcher│   │ 🎨 Designer   │   │ 🧬 Tech       │
│ 📚 Knowledge │   │               │   │               │
└───────────────┘   └───────────────┘   └───────────────┘
        │                    │                    │
        └────────────────────┼────────────────────┘
                             │
                             ▼
                    ┌───────────────┐
                    │  NotebookLM   │
                    │ (外部增强能力) │
                    └───────────────┘
```

---

## 七角色清单

| # | 角色 | 代号 | 核心职责 | 侧重点 |
|---|------|------|----------|--------|
| 1 | 笔杆子 | Writer | 文档撰写、内容编辑 | 内容输出 |
| 2 | 参谋 | Researcher | 调研分析、结构化输出 | 信息 + 洞察 |
| 3 | 运营官 | OPS | 任务管理、流程设计 | 协调 + 监控 |
| 4 | 研发官 | Developer | 代码开发、工具构建 | 技术实现 |
| 5 | 设计师 | Designer | 视觉创作、PPT/图片 | 视觉输出 |
| 6 | 知识工程师 | Knowledge | 知识库、NotebookLM 集成 | 知识管理 ✨ |
| 7 | 进化官 | Tech | 技能沉淀、系统优化 | 持续进化 |

---

## NotebookLM 增强点

### 直接影响的角色

| 角色 | 增强能力 | 实现方式 |
|------|----------|----------|
| Researcher | Data Table、引用溯源、思维导图 | 阶段一调用 NotebookLM，阶段二本地化 |
| Designer | Slide Deck、Infographic | 阶段一调用 NotebookLM，阶段二本地化 |
| Knowledge | 14+ 种结构化输出 | 直接集成 NotebookLM |

### 新增能力清单

| 能力 | 来源 | 负责角色 |
|------|------|----------|
| Data Table 数据对比表 | NotebookLM | Knowledge + Researcher |
| Mind Map 思维导图 | NotebookLM | Knowledge + Designer |
| Slide Deck PPT | NotebookLM | Knowledge + Designer |
| Infographic 信息图 | NotebookLM | Designer |
| Briefing Doc 简报 | NotebookLM | Knowledge + Writer |
| Study Guide 学习指南 | NotebookLM | Knowledge |
| Flashcards 抽认卡 | NotebookLM | Knowledge |
| Quiz 测验题 | NotebookLM | Knowledge |
| Audio Overview 音频 | NotebookLM | 暂不集成（TTS 替代） |
| Video Overview 视频 | NotebookLM | 暂不集成（Designer 替代） |

---

## 角色协作流程

### 标准任务流程

```
MAX 输入 → 无牙分析 → 角色匹配 → 执行 → 质量把关 → 交付
```

### 复杂任务流程（多角色协作）

```
MAX 输入
   │
   ▼
无牙任务拆解
   │
   ├─→ Researcher 搜集信息
   │        │
   │        ▼
   │   Knowledge 结构化
   │        │
   ├─→ Writer 撰写内容
   │        │
   ├─→ Designer 视觉化
   │        │
   └─→ Tech 沉淀知识库
            │
            ▼
        无牙整合 → 交付 MAX
```

### NotebookLM 集成流程（阶段一）

```
MAX 上传文档
   │
   ▼
Knowledge 预处理
   │
   ▼
browser 自动化上传 NotebookLM
   │
   ▼
选择输出格式（Data Table/Slide Deck/Mind Map）
   │
   ▼
抓取解析结果
   │
   ▼
无牙整合 + 本地补充
   │
   ▼
交付 MAX
```

---

## 技能目录结构

```
skills/roles/
├── writer/SKILL.md       — 笔杆子
├── researcher/SKILL.md   — 参谋（已增强）
├── ops/SKILL.md          — 运营官
├── developer/SKILL.md    — 研发官
├── designer/SKILL.md     — 设计师（已增强）
├── knowledge/SKILL.md    — 知识工程师 ✨ 新增
├── tech/SKILL.md         — 进化官
└── ROLES_GUIDE.md        — 应用指南（v2.0）
```

---

## 实施计划

### 已完成 ✅

- [x] 创建 Knowledge 角色 SKILL.md
- [x] 增强 Researcher 结构化输出能力
- [x] 增强 Designer 视觉生成能力
- [x] 更新 MEMORY.md 角色架构
- [x] 更新 ROLES_GUIDE.md 为 v2.0
- [x] 创建架构文档

### 阶段一（1-2 周）🔄

- [ ] 创建 `notebooklm-integration` 技能
- [ ] 实现浏览器自动化上传
- [ ] 实现结果抓取解析
- [ ] 测试 Data Table 输出
- [ ] 测试 Slide Deck 输出
- [ ] 测试 Mind Map 输出

### 阶段二（1 个月）📋

- [ ] Data Table 本地化（Researcher + Developer）
- [ ] Mind Map 本地化（Designer）
- [ ] Slide Deck 本地化（Designer）
- [ ] 创建 SOP 文档

### 阶段三（持续）🔄

- [ ] 常规任务本地处理
- [ ] 复杂任务调用 NotebookLM
- [ ] 持续优化协作流程

---

## 使用示例

### 示例 1：竞品分析

```
MAX: "分析这 5 个竞品的功能对比，要数据表"

无牙:
1. Researcher → 搜集 5 个竞品信息
2. Knowledge → 调用 NotebookLM 生成 Data Table
3. Designer → 制作可视化对比图
4. Writer → 撰写分析结论
5. 整合交付
```

### 示例 2：项目知识库

```
MAX: "把这 10 份项目文档整理成知识库"

无牙:
1. Knowledge → 上传 NotebookLM 批量处理
2. Knowledge → 生成 Briefing Doc + Mind Map
3. Knowledge → 创建知识标签和索引
4. Tech → 归档到飞书知识库
5. 交付知识库链接
```

### 示例 3：学习材料

```
MAX: "帮我理解这份技术文档，要做成学习材料"

无牙:
1. Knowledge → 上传 NotebookLM
2. Knowledge → 生成 Learning Guide + Flashcards + Quiz
3. Researcher → 补充技术背景
4. 交付学习材料包（文档 + 抽认卡 + 测验）
```

---

## 安全与边界

### 文档上传规则

| 文档类型 | 是否可上传 NotebookLM | 说明 |
|----------|----------------------|------|
| 公开文档 | ✅ 可以 | 无限制 |
| 内部文档 | ⚠️ 需确认 | 非敏感可上传 |
| 敏感文档 | ❌ 禁止 | 本地处理 |
| 涉密文档 | ❌ 禁止 | 本地处理 |
| 个人隐私 | ❌ 禁止 | 本地处理 |

### 角色调用边界

| 角色 | 可直接执行 | 需确认 | 禁止执行 |
|------|-----------|--------|----------|
| Writer | 文档撰写 | 对外发布 | 伪造信息 |
| Researcher | 信息搜集 | 付费信息 | 编造数据 |
| OPS | 任务跟踪 | 跨系统操作 | 越权协调 |
| Developer | 代码开发 | 生产部署 | 未授权访问 |
| Designer | 视觉设计 | 商用素材 | 侵权内容 |
| Knowledge | 知识整理 | 上传 NotebookLM | 涉密上传 |
| Tech | 复盘总结 | 架构变更 | 删除文档 |

---

## 总结

**v2.0 核心变化：**

1. **新增 Knowledge 角色** — 专注知识管理与 NotebookLM 集成
2. **增强 Researcher** — 结构化输出能力（Data Table、思维导图）
3. **增强 Designer** — 视觉生成能力（Slide Deck、Infographic）
4. **明确 NotebookLM 协作流程** — 阶段一间接集成，阶段二能力内化

**预期效果：**

- 结构化输出效率 +50%
- 知识库建设效率 +100%
- 整体交付质量 +30%

---

**下一步：** 等待 MAX 确认后启动阶段一实施。
