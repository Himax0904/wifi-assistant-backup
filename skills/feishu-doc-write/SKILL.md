---
name: feishu-doc-write
description: 飞书文档写入技能。提供可靠的文档内容写入方法，避免 API 写入失败问题。Use when: 需要创建或更新飞书文档内容、写入报告、记录日志、生成文档。
---

# Feishu Doc Write 技能

## 问题复盘

### 问题描述

**时间**: 2026-03-02  
**现象**: 使用 `feishu_doc` 工具的 `action: write` 创建文档时，文档只有标题，没有内容。

**受影响操作**:
```yaml
feishu_doc:
  action: write
  doc_token: "xxx"
  content: "# 标题\n\n正文内容"  # ❌ 内容不会被写入
```

**结果**: 文档创建成功，但 `block_count: 1`，只有标题页，没有正文内容。

---

### 原因分析

1. **API 限制**: 飞书文档 API 的 `write` 操作可能不支持直接写入 markdown 格式内容
2. **参数格式**: `content` 参数可能需要特定格式（如 blocks 数组），而非 markdown 文本
3. **权限问题**: 初始创建时可能缺少某些写入权限（但后续 append 成功，排除此原因）

**验证结果**:
- `action: create` + `content` → ❌ 只有标题
- `action: write` + `content` → ❌ 内容不更新
- `action: append` + `content` → ✅ 成功添加内容块

---

### 解决方案

**使用 `append` 方式分块写入内容**

```yaml
# 步骤 1: 创建空文档
feishu_doc:
  action: create
  title: "文档标题"
  # 不传 content 参数

# 步骤 2: 分块添加内容
feishu_doc:
  action: append
  doc_token: "文档 token"
  content: "第一段内容"  # ✅ 纯文本或简单 markdown

# 步骤 3: 继续添加更多内容
feishu_doc:
  action: append
  doc_token: "文档 token"
  content: "第二段内容"  # ✅ 每次 append 添加新块
```

---

## 最佳实践

### 1. 创建文档流程

```yaml
# 推荐流程
1. create (仅标题) → 获取 doc_token
2. append (内容块 1) → 添加第一段
3. append (内容块 2) → 添加第二段
4. ... 继续 append 直到完成
```

### 2. 内容分块策略

| 内容类型 | 分块建议 |
|----------|----------|
| 标题 (#) | 单独一块 |
| 小标题 (##) | 单独一块 |
| 段落文本 | 每段一块 |
| 列表 | 每个列表一块 |
| 代码块 | 单独一块 |
| 表格 | 单独一块（或拆分为多块） |

### 3. 内容格式建议

**✅ 推荐格式**:
```
纯文本
简单 markdown（# 标题，- 列表）
每块内容 < 1000 字
```

**❌ 避免格式**:
```
复杂嵌套 markdown
超长内容 (>5000 字/块)
特殊 HTML 标签
```

---

## 使用示例

### 示例 1: 创建报告文档

```yaml
# 步骤 1: 创建空文档
feishu_doc:
  action: create
  title: "技能落地报告 - 2026-03-02"

# 步骤 2: 添加标题
feishu_doc:
  action: append
  doc_token: "上一步返回的 doc_token"
  content: "技能落地报告"

# 步骤 3: 添加元信息
feishu_doc:
  action: append
  doc_token: "doc_token"
  content: "创建时间：2026-03-02 11:35\n创建者：无牙\n状态：完成"

# 步骤 4: 添加技能列表
feishu_doc:
  action: append
  doc_token: "doc_token"
  content: "3 个新技能详情\n\n1. ssh-remote (SSH 远程服务器管理)\n功能：SSH 连接、远程命令、文件传输、服务监控\n安全：红线需 MAX 确认，黄线先问询，绿线直通\n配置：ssh_hosts.yaml"

# 步骤 5: 添加文件状态
feishu_doc:
  action: append
  doc_token: "doc_token"
  content: "本地文件状态\n\nskills/ssh-remote/SKILL.md - 124 行 - 完成\nskills/auto-backup/SKILL.md - 156 行 - 完成\nskills/knowledge-analytics/SKILL.md - 218 行 - 完成\n\n总计 898 行，所有文件完整可用。"
```

### 示例 2: 更新现有文档

```yaml
# 追加新内容到现有文档
feishu_doc:
  action: append
  doc_token: "已知 doc_token"
  content: "最新更新：2026-03-02 12:00\n\n新增内容：核心引擎实现完成"
```

### 示例 3: 写入日报

```yaml
# 创建日报
feishu_doc:
  action: create
  title: "日报 - 2026-03-02"

# 添加内容
feishu_doc:
  action: append
  doc_token: "上一步返回的 doc_token"
  content: "今日完成\n\n1. 技能开发：ssh-remote, auto-backup, knowledge-analytics\n2. 测试验证：飞书文档 API 写入测试\n3. 问题复盘：飞书文档写入问题记录"

feishu_doc:
  action: append
  doc_token: "doc_token"
  content: "明日计划\n\n1. 实现核心引擎\n2. 配置生产参数\n3. 端到端测试"
```

---

## 错误处理

### 错误 1: append 失败 (400)

**原因**: 内容格式问题（markdown 太复杂）

**解决**:
```yaml
# 简化内容格式
content: "纯文本内容"  # 避免复杂 markdown
```

### 错误 2: doc_token 无效

**原因**: 文档不存在或权限不足

**解决**:
```yaml
# 检查 doc_token 是否正确
# 确认有写入权限 (docx:document:write_only)
```

### 错误 3: 内容未显示

**原因**: 可能需要刷新或 API 延迟

**解决**:
```yaml
# 等待 1-2 秒后读取验证
feishu_doc:
  action: read
  doc_token: "doc_token"
```

---

## 权限要求

需要以下飞书 API 权限：

| 权限 | 用途 |
|------|------|
| `docx:document:create` | 创建文档 |
| `docx:document:write_only` | 写入内容 |
| `docx:document:readonly` | 读取验证 |
| `docs:permission.setting:write_only` | 设置权限（可选） |

---

## 相关文件

- 技能目录：`skills/feishu-doc-write/`
- 测试文档：飞书文档（通过 append 创建）
- 复盘记录：本 SKILL.md

---

## 经验总结

### 教训

1. **不要假设 API 行为**: 即使文档说支持 `content` 参数，实际可能不工作
2. **及时验证**: 创建后应立即 `read` 验证内容是否正确写入
3. **分块写入**: 大内容分块写入更可靠，便于调试

### 最佳实践

1. **create + append 组合**: 先创建空文档，再 append 内容
2. **简单内容格式**: 使用纯文本或简单 markdown
3. **逐步验证**: 每步 append 后检查 `blocks_added` 返回值
4. **记录 doc_token**: 创建后立即保存 doc_token 供后续使用

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| 1.0 | 2026-03-02 | 初始版本，记录飞书文档写入问题复盘 |

---

**创建时间**: 2026-03-02 11:40  
**状态**: 完成
