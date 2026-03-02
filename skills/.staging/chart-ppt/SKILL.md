---
name: chart-ppt
description: 图表和 PPT 生成技能。支持数据图表生成、PPT 幻灯片创建、报告生成、可视化展示。Use when: 需要制作图表、创建 PPT、生成报告、数据可视化展示。【储备技能，待 MAX 激活】
---

# Chart & PPT 技能

**状态**: 🟡 储备中  
**方向**: 图表/PPT 生成  
**创建时间**: 2026-03-02

---

## 核心能力

### 1. 图表生成
- 折线图（趋势分析）
- 柱状图（对比分析）
- 饼图（占比分析）
- 散点图（相关性）
- 雷达图（多维度）
- 热力图（密度分布）

### 2. PPT 创建
- 幻灯片模板
- 标题页
- 内容页
- 图表页
- 总结页
- 导出为 PPTX/PDF

### 3. 数据可视化
- CSV/Excel 数据导入
- 数据清洗
- 自动图表选择
- 配色方案
- 图例标注

### 4. 报告生成
- 周报/月报模板
- 数据报告
- 分析报告
- 导出为 PDF/Word

---

## 使用示例

### 示例 1: 生成销售图表
```
根据这个销售数据生成柱状图
→ 读取数据
→ 选择图表类型
→ 生成图表
→ 保存为 PNG/PDF
```

### 示例 2: 创建周报 PPT
```
创建一份周报 PPT，包含本周完成、下周计划
→ 选择模板
→ 生成标题页
→ 生成内容页
→ 导出 PPTX
```

### 示例 3: 数据可视化
```
把这个 Excel 数据转为可视化图表
→ 读取 Excel
→ 分析数据结构
→ 自动选择图表
→ 生成多个图表
```

### 示例 4: 月度报告
```
生成月度分析报告，包含趋势和对比
→ 汇总数据
→ 生成分析文本
→ 创建图表
→ 整合为报告
```

---

## 配置示例

```yaml
# ~/.openclaw/workspace/chart_ppt_config.yaml
chart_ppt:
  enabled: false  # 待激活
  chart:
    default_width: 800
    default_height: 600
    dpi: 150
    format: png  # png, svg, pdf
    style: default
    palette: 
      - "#52c41a"
      - "#1890ff"
      - "#faad14"
      - "#f5222d"
  ppt:
    template: default
    aspect_ratio: 16:9
    font: Arial
    font_size: 24
    output_format: pptx  # pptx, pdf
  output_dir: ~/reports/
```

---

## 依赖库

| 库 | 用途 | 安装 |
|------|------|------|
| matplotlib | 图表生成 | pip install matplotlib |
| seaborn | 统计图表 | pip install seaborn |
| plotly | 交互图表 | pip install plotly |
| python-pptx | PPT 生成 | pip install python-pptx |
| reportlab | PDF 生成 | pip install reportlab |

---

## 输出格式

| 类型 | 格式 | 说明 |
|------|------|------|
| 图表 | PNG, SVG, PDF | 静态图片/矢量图 |
| PPT | PPTX, PDF | PowerPoint/ PDF |
| 报告 | PDF, DOCX, Markdown | 文档格式 |

---

**状态**: 🟡 储备中  
**激活条件**: MAX 发出"激活 chart-ppt 技能"
