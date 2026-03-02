---
name: data-visualization
description: 数据可视化技能。支持读取 CSV/Excel/Bitable 数据生成图表、自动报告。Use when: 需要将数据转为图表、生成可视化报告、定时产出业务数据追踪报表。
---

# Data Visualization 技能

## 安全属性

| 级别 | 操作类型 | 执行方式 |
|------|----------|----------|
| 🔴 红线 | 删除原始数据、对外发布敏感数据报告 | 必须 MAX 明确确认，无确认不执行 |
| 🟡 黄线 | 访问隐私数据、生成含个人信息的报告 | 先问询 MAX，确认后执行 |
| 🟢 绿线 | 读取业务数据、生成内部图表、定时日报 | 直接执行，事后简报 |

## 核心能力

### 1. 数据源支持
- **CSV/Excel**：本地文件读取
- **飞书 Bitable**：通过 feishu_bitable_* 工具
- **飞书文档**：表格数据提取

### 2. 图表类型
- 折线图 (趋势分析)
- 柱状图 (对比分析)
- 饼图 (占比分析)
- 表格 (数据明细)

### 3. 输出格式
- 飞书文档嵌入
- 图片导出 (PNG/JPG)
- Markdown 表格

## 使用示例

### 示例 1：销售数据周报
```
读取 Bitable 销售表 → 生成本周趋势图 → 嵌入飞书文档
```

### 示例 2：项目进度看板
```
读取任务数据 → 生成完成/进行中/未开始饼图 → 发送日报
```

### 示例 3：自动日报
```
每天 18:00 → 汇总当日数据 → 生成图表 → 发送飞书
```

## 配置格式

可视化配置位于 `~/.openclaw/workspace/visualizations/`，YAML 格式：

```yaml
name: sales-weekly
data_source:
  type: bitable
  app_token: "xxx"
  table_id: "xxx"
charts:
  - type: line
    title: "本周销售趋势"
    x_field: date
    y_field: revenue
  - type: pie
    title: "产品分类占比"
    field: category
output:
  type: feishu_doc
  safety_level: green
```

## 安全执行流程

1. 读取数据源配置
2. 检查数据敏感度 (safety_level)
3. 🔴 红线操作 → 暂停，请求 MAX 确认
4. 🟡 黄线操作 → 暂停，请求 MAX 确认
5. 🟢 绿线操作 → 直接执行
6. 生成图表并输出
7. 记录执行日志到飞书日报

## 相关文件

- 可视化配置目录：`~/.openclaw/workspace/visualizations/`
- 输出目录：`~/.openclaw/workspace/charts/`
- 执行日志：飞书日报文档
