# 储备技能库

**用途**: 存放已开发但未激活的技能，待 MAX 需要时启用

---

## 储备技能列表

| 技能 | 方向 | 状态 | 创建时间 |
|------|------|------|----------|
| token-optimizer | Token 优化 | 🟡 储备 | 2026-03-02 |

## 已激活技能（从储备库）

| 技能 | 方向 | 激活时间 |
|------|------|----------|
| code-helper | 开发辅助 | 2026-03-03 |
| multi-media | 多媒体处理 | 2026-03-03 |
| chart-ppt | 图表/PPT | 2026-03-03 |

---

## 激活方式

向 Wi-Fi 发出指令：

```
激活 <技能名称> 技能
```

例如：
- "激活 code-helper 技能"
- "激活 multi-media 技能"
- "激活 chart-ppt 技能"

---

## 技能详情

### token-optimizer
- **用途**: 优化 Token 消耗，降低成本
- **预计节省**: 50-70%
- **优先级**: 高

### code-helper
- **用途**: 代码审查、调试、生成、测试
- **支持语言**: Python, JS/TS, Go, Java, Shell
- **优先级**: 高

### multi-media
- **用途**: 图像、音频、视频处理
- **支持格式**: JPG, PNG, WebP, MP3, MP4 等
- **优先级**: 中

### chart-ppt
- **用途**: 图表生成、PPT 创建、报告生成
- **输出格式**: PNG, SVG, PPTX, PDF
- **优先级**: 中

---

## 目录结构

```
.staging/
├── README.md              # 本文件
├── token-optimizer/
│   └── SKILL.md
├── code-helper/
│   └── SKILL.md
├── multi-media/
│   └── SKILL.md
└── chart-ppt/
    └── SKILL.md
```

---

## 移动到生产

当 MAX 确认激活某个技能时：

1. 将技能目录从 `.staging/` 移动到 `skills/`
2. 更新配置文件
3. 安装依赖
4. 测试验证
5. 提交 Git

---

**最后更新**: 2026-03-02
