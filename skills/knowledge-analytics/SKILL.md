---
name: knowledge-analytics
description: 知识与数据分析技能。支持知识整理、数据统计、趋势分析、洞察提取、报告生成。Use when: 需要分析项目进度、汇总任务数据、提取文档洞察、生成分析报告、同比环比分析、异常检测。
---

# Knowledge Analytics 技能

## 安全属性

| 级别 | 操作类型 | 执行方式 |
|------|----------|----------|
| 🔴 红线 | 删除原始数据、对外发布分析报告、分享敏感分析结果给第三方 | 必须 MAX 明确确认，无确认不执行 |
| 🟡 黄线 | 分析隐私数据 (个人 memory、私人文档)、访问敏感飞书文档、包含个人信息的数据分析 | 先问询 MAX，确认后执行 |
| 🟢 绿线 | 读取公开文档、统计分析工作区数据、生成内部报告、计算指标、趋势分析 | 直接执行，事后简报 |

## 核心能力

### 1. 知识整理
- 自动分类文档 (按主题/项目/时间)
- 关键词提取 (TF-IDF, TextRank)
- 自动打标签
- 知识图谱构建 (实体关系)

### 2. 数据统计
- 多源数据汇总 (飞书/本地/CSV/Excel)
- 指标计算 (完成率、效率、趋势)
- 数据清洗与标准化
- 异常值检测

### 3. 趋势分析
- 时间序列分析
- 同比分析 (与上周/上月/去年同期)
- 环比分析 (与上期对比)
- 趋势预测 (简单线性回归)

### 4. 洞察提取
- 从数据中生成结论
- 风险识别与提示
- 机会点发现
- 建议生成

### 5. 报告生成
- 自动产出分析报告
- 文字总结 + 数据图表
- 支持多种格式 (Markdown/飞书文档)
- 定时报告 (日报/周报/月报)

## 配置格式

分析配置位于 `~/.openclaw/workspace/analytics_config.yaml`：

```yaml
# 全局设置
global:
  output_format: markdown
  include_charts: true
  language: zh-CN
  notify_on_complete: true

# 数据源
data_sources:
  local:
    - path: ~/.openclaw/workspace/memory/
      type: markdown
      tags: [daily, memory]
    - path: ~/.openclaw/workspace/test_data/
      type: markdown
      tags: [test, projects]
    - path: ~/.openclaw/workspace/charts/
      type: text
      tags: [charts]
  
  feishu:
    - doc_token: "daily_report_xxx"
      title: "日报"
      type: docx
    - doc_token: "weekly_report_yyy"
      title: "周报"
      type: docx
  
  files:
    - path: ~/data/tasks.csv
      type: csv
    - path: ~/data/metrics.xlsx
      type: excel

# 分析任务
analyses:
  - name: weekly-summary
    description: 每周工作总结
    sources:
      - type: local
        path: ~/.openclaw/workspace/memory/
        date_range: last_7_days
      - type: feishu
        doc_tokens:
          - "daily_report_xxx"
    metrics:
      - name: task_completion_rate
        description: 任务完成率
        formula: completed / total * 100
      - name: time_spent
        description: 总工时
        unit: hours
      - name: skill_development
        description: 技能开发数量
        count: skills_created
    output:
      - summary_text
      - trend_chart
      - metric_table
    schedule: "0 18 * * 5"  # 每周五 18:00
    safety_level: green

  - name: project-progress
    description: 项目进度分析
    sources:
      - type: local
        path: ~/.openclaw/workspace/test_data/projects/
    analysis:
      - task_status_distribution
      - time_tracking
      - risk_identification
    output:
      - progress_report
      - risk_alerts
      - recommendations
    safety_level: green

  - name: memory-insights
    description: 记忆文件洞察
    sources:
      - type: local
        path: ~/.openclaw/workspace/memory/
    analysis:
      - keyword_extraction
      - topic_clustering
      - timeline_summary
    output:
      - insights_report
      - keyword_cloud
      - topic_summary
    safety_level: yellow  # 涉及个人记忆

  - name: monthly-report
    description: 月度综合报告
    sources:
      - type: all
    metrics:
      - all_metrics
    analysis:
      - trend_analysis
      - yoy_comparison
      - mom_comparison
    output:
      - full_report
      - executive_summary
      - charts_package
    schedule: "0 10 1 * *"  # 每月 1 号 10:00
    safety_level: green
```

## 使用示例

### 示例 1: 分析本周工作 (绿线)
```
分析本周工作完成情况
→ 读取 memory 文件和日报
→ 计算任务完成率、工时
→ 生成总结报告
→ 返回分析结果
```

### 示例 2: 项目进度分析 (绿线)
```
分析项目进度，给出风险提示
→ 读取项目文档
→ 统计任务状态
→ 识别延期风险
→ 生成建议
```

### 示例 3: 记忆文件洞察 (黄线)
```
从记忆文件中提取关键主题
→ 问询 MAX 确认
→ 关键词提取
→ 主题聚类
→ 生成洞察报告
```

### 示例 4: 月度同比分析 (绿线)
```
对比本月和上月的工作情况
→ 读取两个月的数据
→ 计算同比变化
→ 分析增长/下降原因
→ 生成对比报告
```

### 示例 5: 发布分析报告 (红线)
```
将分析报告发送到外部
→ 请求 MAX 明确确认
→ 确认后发送
→ 记录操作日志
```

## 安全执行流程

1. 解析分析请求，识别数据源
2. 检查数据源 safety_level
3. 🔴 红线操作 → 暂停，请求 MAX 明确确认
4. 🟡 黄线操作 → 暂停，问询 MAX
5. 🟢 绿线操作 → 直接执行
6. 读取数据，执行分析
7. 生成报告和洞察
8. 记录操作日志到飞书日报

## 指标定义

### 任务相关指标
```yaml
task_completion_rate: 完成任务数 / 总任务数 * 100
task_efficiency: 完成任务数 / 总工时
avg_task_time: 总工时 / 完成任务数
overdue_rate: 延期任务数 / 总任务数 * 100
```

### 时间相关指标
```yaml
total_hours: 总工时
productive_hours: 有效工时
focus_time: 专注时间
meeting_time: 会议时间
```

### 成长相关指标
```yaml
skills_created: 新创建技能数
docs_written: 文档撰写数
lessons_learned: 经验总结数
```

## 分析方法

### 1. 关键词提取
```
算法：TF-IDF + TextRank
输入：文档集合
输出：Top-N 关键词及权重
```

### 2. 主题聚类
```
算法：K-Means / LDA
输入：文档向量
输出：主题分类及文档归属
```

### 3. 趋势分析
```
方法：移动平均、线性回归
输入：时间序列数据
输出：趋势线、预测值
```

### 4. 异常检测
```
方法：Z-Score、IQR
输入：指标数据
输出：异常点及原因分析
```

### 5. 同比环比
```
同比：(本期 - 去年同期) / 去年同期 * 100%
环比：(本期 - 上期) / 上期 * 100%
```

## 报告模板

### 日报模板
```markdown
# 日报 - {date}

## 今日完成
- 任务 1
- 任务 2

## 关键指标
- 任务完成率：X%
- 工时：Xh

## 明日计划
- 计划 1
- 计划 2
```

### 周报模板
```markdown
# 周报 - Week {week}

## 本周总结
{文字总结}

## 关键指标
| 指标 | 本周 | 上周 | 变化 |
|------|------|------|------|
| 任务完成率 | X% | Y% | +Z% |
| 总工时 | Xh | Yh | +Zh |

## 趋势分析
{趋势图表}

## 风险与建议
- 风险 1
- 建议 1
```

### 月报模板
```markdown
# 月报 - {month}

## 执行摘要
{高层摘要}

## 月度指标
{指标表格}

## 同比分析
{与上月/去年同期对比}

## 亮点与不足
- 亮点 1
- 不足 1

## 下月计划
{计划列表}
```

## 相关文件

- 分析配置：`~/.openclaw/workspace/analytics_config.yaml`
- 数据源：`memory/`, `test_data/`, 飞书文档
- 输出目录：`~/.openclaw/workspace/reports/`
- 操作日志：飞书日报文档

## 数据隐私

### 敏感数据处理
- 个人 memory 文件 → 黄线操作，需确认
- 飞书私密文档 → 黄线操作，需确认
- 含个人信息的数据 → 脱敏处理后分析

### 数据保留
- 分析结果 → 保留 90 天
- 原始数据 → 不存储，仅读取
- 中间缓存 → 分析完成后清理

## 错误处理

| 错误类型 | 处理方式 |
|----------|----------|
| 数据源不可用 | 跳过该源，继续分析其他源 |
| 数据格式错误 | 报告错误，尝试自动修复 |
| 分析失败 | 返回部分结果，标注失败项 |
| 安全策略拦截 | 记录拦截日志，报告 MAX |

## 审计日志

每次分析操作记录：
- 时间戳
- 分析任务名称
- 数据源列表
- 分析类型
- 生成报告数量
- 耗时
- 安全级别
- MAX 确认记录 (如适用)

日志同步至飞书日报文档。
