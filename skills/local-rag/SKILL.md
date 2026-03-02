---
name: local-rag
description: 本地 RAG 知识库技能。支持私有文档索引、语义搜索、问答带引用。Use when: 需要检索历史文档/会议记录/项目资料、基于私有知识库回答问题、完全本地运行确保隐私安全。
---

# Local RAG 知识库技能

## 安全属性

| 级别 | 操作类型 | 执行方式 |
|------|----------|----------|
| 🔴 红线 | 对外分享知识库内容、索引含敏感权限的文档 | 必须 MAX 明确确认，无确认不执行 |
| 🟡 黄线 | 索引个人隐私文档、访问飞书私密文档 | 先问询 MAX，确认后执行 |
| 🟢 绿线 | 索引公开项目文档、内部资料检索、问答 | 直接执行，事后简报 |

## 核心能力

### 1. 文档索引
- **本地文档**：Markdown、PDF、TXT
- **飞书文档**：通过 feishu_doc 读取
- **网页内容**：通过 web_fetch 抓取

### 2. 语义搜索
- 向量相似度检索
- 关键词搜索
- 混合检索 (向量 + 关键词)

### 3. 问答
- 基于索引内容回答
- 带引用来源标注
- 支持多文档综合回答

## 架构设计

```
文档 → 分块 → 向量化 → 存储 (本地)
                ↓
用户问题 → 向量化 → 检索 → 回答 + 引用
```

## 使用示例

### 示例 1：项目资料检索
```
索引项目文档 → 提问"上次会议纪要是什么" → 返回带引用的答案
```

### 示例 2：历史对话查询
```
索引 memory 文件 → 提问"之前讨论过什么技能" → 返回相关记录
```

### 示例 3：飞书文档问答
```
索引飞书文档 → 提问"XX 项目的进度如何" → 从文档中提取答案
```

## 配置格式

知识库配置位于 `~/.openclaw/workspace/knowledge_bases/`，YAML 格式：

```yaml
name: project-docs
sources:
  - type: local
    path: ~/.openclaw/workspace/projects/
  - type: feishu
    doc_tokens:
      - "doc_xxx"
  - type: web
    urls:
      - "https://example.com/docs"
index_settings:
  chunk_size: 500
  chunk_overlap: 50
  embedding_model: local
safety_level: green
```

## 安全执行流程

1. 检查文档来源安全级别
2. 🔴 红线文档 → 暂停，请求 MAX 确认
3. 🟡 黄线文档 → 暂停，请求 MAX 确认
4. 🟢 绿线文档 → 直接索引
5. 问答时检查引用内容安全级别
6. 记录索引和问答日志到飞书日报

## 技术实现

### 向量化
- 使用本地 embedding 模型 (如 sentence-transformers)
- 或调用 API (需 MAX 确认)

### 存储
- 本地向量数据库 (如 Chroma、FAISS)
- 存储路径：`~/.openclaw/workspace/vectorstore/`

### 检索
- 相似度阈值过滤
- Top-K 结果返回

## 相关文件

- 知识库配置目录：`~/.openclaw/workspace/knowledge_bases/`
- 向量存储目录：`~/.openclaw/workspace/vectorstore/`
- 索引日志：飞书日报文档

## 隐私保护

- 所有数据本地存储，不上传外部
- 索引前检查文档权限
- 问答时不泄露未授权内容
