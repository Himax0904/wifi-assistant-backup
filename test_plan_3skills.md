# 三技能联动测试方案

**测试目标**: 验证 workflow-automation + local-rag + data-visualization 三个技能的协同工作能力

**测试日期**: 2026-03-02  
**测试人员**: Wi-Fi 📡

---

## 测试场景：项目周报自动生成

### 场景描述

```
每周五 18:00 自动触发 →
  1. 从本地知识库检索本周项目文档 (local-rag) →
  2. 提取任务完成数据 (workflow-automation) →
  3. 生成可视化周报图表 (data-visualization) →
  4. 发送飞书日报 (workflow-automation)
```

---

## 测试数据准备

### 1. 项目文档 (供 local-rag 索引)

创建测试文档：`~/.openclaw/workspace/test_data/projects/week10.md`

```markdown
# 项目周报 - Week 10

## 任务完成情况

| 任务 | 状态 | 负责人 | 工时 |
|------|------|--------|------|
| 技能开发 | 已完成 | Wi-Fi | 8h |
| 测试方案 | 进行中 | Wi-Fi | 4h |
| 安全审计 | 未开始 | - | 0h |

## 关键指标
- 完成任务数：1
- 进行中任务数：1
- 总工时：12h
```

### 2. 工作流配置 (workflow-automation)

创建配置：`~/.openclaw/workspace/workflows/weekly-report-test.yaml`

```yaml
name: weekly-report-test
trigger:
  type: manual  # 测试用手动触发
  # 生产环境：type: cron, expression: "0 18 * * 5"

pipeline:
  - step: retrieve_docs
    skill: local-rag
    params:
      query: "本周项目任务完成情况"
      top_k: 5
    safety_level: green

  - step: extract_data
    skill: workflow-automation
    params:
      action: parse_markdown_table
      source: previous_step.output
    safety_level: green

  - step: generate_charts
    skill: data-visualization
    params:
      charts:
        - type: pie
          title: "任务状态分布"
          data_field: status
        - type: bar
          title: "工时统计"
          x_field: task
          y_field: hours
      output_format: png
    safety_level: green

  - step: send_report
    skill: workflow-automation
    params:
      action: send_feishu_message
      content: "周报已生成，请查看"
      attachments: previous_step.charts
    safety_level: green  # 内部发送
```

### 3. 可视化配置 (data-visualization)

创建配置：`~/.openclaw/workspace/visualizations/weekly-report-test.yaml`

```yaml
name: weekly-report-test
data_source:
  type: markdown
  path: ~/.openclaw/workspace/test_data/projects/week10.md
  table_selector: "任务完成情况"

charts:
  - type: pie
    title: "任务状态分布"
    field: status
    colors:
      已完成: "#52c41a"
      进行中: "#1890ff"
      未开始: "#d9d9d9"

  - type: bar
    title: "工时统计"
    x_field: task
    y_field: hours
    orientation: vertical

output:
  type: png
  path: ~/.openclaw/workspace/charts/weekly-report-test/
  safety_level: green
```

### 4. 知识库配置 (local-rag)

创建配置：`~/.openclaw/workspace/knowledge_bases/project-docs-test.yaml`

```yaml
name: project-docs-test
sources:
  - type: local
    path: ~/.openclaw/workspace/test_data/projects/
    file_pattern: "*.md"

index_settings:
  chunk_size: 500
  chunk_overlap: 50
  embedding_model: local

safety_level: green
```

---

## 测试执行步骤

### Step 1: 索引知识库 (local-rag)

```bash
# 创建测试数据目录
mkdir -p ~/.openclaw/workspace/test_data/projects/

# 写入测试文档
# (见上方 week10.md 内容)

# 执行索引
openclaw skill run local-rag \
  --action index \
  --config ~/.openclaw/workspace/knowledge_bases/project-docs-test.yaml
```

**预期结果**:
- ✅ 文档成功分块
- ✅ 向量存储生成
- ✅ 索引日志记录

**验证命令**:
```bash
ls -la ~/.openclaw/workspace/vectorstore/project-docs-test/
```

---

### Step 2: 测试知识库检索 (local-rag)

```bash
openclaw skill run local-rag \
  --action query \
  --config ~/.openclaw/workspace/knowledge_bases/project-docs-test.yaml \
  --query "本周任务完成情况"
```

**预期结果**:
- ✅ 返回相关文档片段
- ✅ 带引用来源标注
- ✅ 无敏感信息泄露

---

### Step 3: 测试数据可视化 (data-visualization)

```bash
openclaw skill run data-visualization \
  --action generate \
  --config ~/.openclaw/workspace/visualizations/weekly-report-test.yaml
```

**预期结果**:
- ✅ 生成饼图 (任务状态分布)
- ✅ 生成柱状图 (工时统计)
- ✅ 图片保存至 `charts/weekly-report-test/`

**验证命令**:
```bash
ls -la ~/.openclaw/workspace/charts/weekly-report-test/
```

---

### Step 4: 测试工作流联动 (workflow-automation)

```bash
openclaw skill run workflow-automation \
  --action execute \
  --config ~/.openclaw/workspace/workflows/weekly-report-test.yaml
```

**预期结果**:
- ✅ 按 pipeline 顺序执行 4 个步骤
- ✅ 每步安全级别检查通过
- ✅ 最终生成报告并发送

---

### Step 5: 安全验证测试

#### 5.1 红线操作拦截测试

修改工作流配置，添加危险操作：

```yaml
  - step: dangerous_test
    skill: workflow-automation
    params:
      action: delete_file
      path: /etc/passwd
    safety_level: red  # 红线操作
```

**预期结果**:
- ❌ 操作被拦截
- ✅ 请求 MAX 确认
- ✅ 日志记录拦截事件

#### 5.2 黄线操作问询测试

```yaml
  - step: yellow_test
    skill: workflow-automation
    params:
      action: send_external_email
      to: external@example.com
    safety_level: yellow
```

**预期结果**:
- ⏸️ 暂停执行
- ✅ 问询 MAX 是否确认
- ✅ 等待确认后继续

---

## 成功标准

| 测试项 | 预期结果 | 实际结果 | 状态 |
|--------|----------|----------|------|
| 知识库索引 | 文档成功向量化 | - | ⏳ |
| 知识库检索 | 返回带引用的答案 | - | ⏳ |
| 图表生成 | 生成 2 张图表 | - | ⏳ |
| 工作流执行 | 4 步骤顺序执行 | - | ⏳ |
| 红线拦截 | 危险操作被阻止 | - | ⏳ |
| 黄线问询 | 敏感操作先确认 | - | ⏳ |
| 绿线直通 | 内部操作直接执行 | - | ⏳ |

---

## 测试时间安排

| 阶段 | 时间 | 负责人 |
|------|------|--------|
| 数据准备 | 2026-03-02 10:00 | Wi-Fi |
| 单技能测试 | 2026-03-02 11:00 | Wi-Fi |
| 联动测试 | 2026-03-02 14:00 | Wi-Fi |
| 安全验证 | 2026-03-02 15:00 | Wi-Fi + MAX |
| 复盘总结 | 2026-03-02 16:00 | Wi-Fi + MAX |

---

## 风险与应对

| 风险 | 影响 | 应对措施 |
|------|------|----------|
| 向量模型不可用 | 索引失败 | 降级为关键词搜索 |
| 图表生成失败 | 报告不完整 | 降级为纯文本报告 |
| 飞书 API 限流 | 发送失败 | 重试 + 本地保存 |
| 安全策略误判 | 正常操作被拦截 | MAX 确认后加入白名单 |

---

## 输出物

1. 测试执行日志 (飞书日报)
2. 生成的图表文件 (`charts/weekly-report-test/`)
3. 测试报告文档
4. 技能迭代建议

---

**审批**: 待 MAX 确认  
**状态**: 方案待执行
