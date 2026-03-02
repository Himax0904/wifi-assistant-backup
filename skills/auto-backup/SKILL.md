---
name: auto-backup
description: 自动备份与同步技能。支持定时备份、飞书文档同步、增量备份、恢复验证。Use when: 需要备份工作区数据、同步飞书文档、增量备份节省空间、验证备份完整性、恢复测试。
---

# Auto Backup 技能

## 安全属性

| 级别 | 操作类型 | 执行方式 |
|------|----------|----------|
| 🔴 红线 | 删除原文件、覆盖备份、外部同步到第三方、备份到公共存储 | 必须 MAX 明确确认，无确认不执行 |
| 🟡 黄线 | 备份隐私数据 (memory/个人文件)、访问敏感目录、加密备份 | 先问询 MAX，确认后执行 |
| 🟢 绿线 | 读取文件、创建备份、验证完整性、本地同步、查看备份状态 | 直接执行，事后简报 |

## 核心能力

### 1. 定时备份
- Cron 表达式配置
- 增量备份 (rsync 算法)
- 全量备份 (定期)
- 备份保留策略 (按天数/版本数)

### 2. 飞书文档同步
- 文档列表同步
- 内容导出 (Markdown)
- 增量更新检测
- 本地版本管理

### 3. 增量备份
- 文件变更检测 (mtime, size, hash)
- 差异备份 (仅备份变化部分)
- 硬链接优化 (节省空间)
- 备份去重

### 4. 恢复验证
- 备份完整性校验 (checksum)
- 定期恢复测试
- 备份报告生成
- 告警通知 (备份失败)

## 配置格式

备份配置位于 `~/.openclaw/workspace/backup_config.yaml`：

```yaml
# 全局设置
global:
  backup_root: ~/backups/
  log_level: info
  notify_on_failure: true
  notify_channel: feishu

# 备份任务
backups:
  - name: workspace-daily
    description: 工作区每日备份
    source: ~/.openclaw/workspace/
    destination: ~/backups/workspace/daily/
    schedule: "0 2 * * *"  # 每天 02:00
    type: incremental
    retention:
      days: 30
      versions: 7
    exclude:
      - "*.log"
      - "node_modules/"
      - ".git/"
      - "vectorstore/"
    safety_level: green

  - name: workspace-weekly
    description: 工作区每周全量备份
    source: ~/.openclaw/workspace/
    destination: ~/backups/workspace/weekly/
    schedule: "0 3 * * 0"  # 每周日 03:00
    type: full
    retention:
      weeks: 12
    safety_level: green

  - name: feishu-docs
    description: 飞书文档同步
    source: feishu_docs
    destination: ~/backups/feishu/
    schedule: "0 3 * * *"  # 每天 03:00
    type: sync
    docs:
      - token: "doc_xxx"
        title: "日报"
      - token: "doc_yyy"
        title: "周报"
    safety_level: yellow

  - name: config-files
    description: 系统配置备份
    source: 
      - ~/.bashrc
      - ~/.ssh/config
      - ~/.openclaw/config.json
    destination: ~/backups/configs/
    schedule: "0 4 * * *"
    type: full
    retention:
      versions: 10
    safety_level: yellow
    encrypt: true

# 恢复验证
verification:
  schedule: "0 5 * * 0"  # 每周日 05:00
  sample_rate: 0.1  # 随机抽取 10% 文件验证
  test_restore: true
  report: true
```

## 使用示例

### 示例 1: 手动备份工作区 (绿线)
```
备份工作区到本地
→ 执行增量备份
→ 返回备份大小、文件数
→ 记录日志
```

### 示例 2: 查看备份状态 (绿线)
```
查看最近的备份
→ 列出备份版本
→ 显示大小、时间
```

### 示例 3: 同步飞书文档 (黄线)
```
同步飞书文档到本地
→ 问询 MAX 确认
→ 导出文档内容
→ 保存到本地
```

### 示例 4: 恢复文件 (绿线)
```
从备份恢复昨天的工作区
→ 列出可用版本
→ 确认后恢复
→ 验证完整性
```

### 示例 5: 删除旧备份 (红线)
```
删除 30 天前的备份
→ 请求 MAX 明确确认
→ 执行删除
→ 记录操作日志
```

## 安全执行流程

1. 解析备份请求，识别源和目标
2. 检查 safety_level
3. 🔴 红线操作 → 暂停，请求 MAX 明确确认
4. 🟡 黄线操作 → 暂停，问询 MAX
5. 🟢 绿线操作 → 直接执行
6. 执行备份，监控进度
7. 验证备份完整性
8. 记录操作日志到飞书日报

## 备份策略

### 增量备份 (推荐日常使用)
```
优点：节省空间、快速
缺点：恢复时需要基础全量备份

适用：每日备份
```

### 全量备份
```
优点：恢复简单、独立完整
缺点：占用空间大、耗时长

适用：每周/每月备份
```

### 差异备份
```
优点：比全量快、比增量恢复简单
缺点：随时间增长变大

适用：折中方案
```

## 保留策略

```yaml
retention:
  days: 30        # 保留 30 天
  versions: 7     # 保留 7 个版本
  weeks: 12       # 保留 12 周
  months: 6       # 保留 6 个月
```

清理规则：
- 超过天数的备份 → 删除
- 超过版本数的旧版本 → 删除
- 保留至少 1 个全量备份

## 文件排除

```yaml
exclude:
  - "*.log"           # 日志文件
  - "*.tmp"           # 临时文件
  - "node_modules/"   # 依赖目录
  - ".git/"           # Git 仓库
  - "__pycache__/"    # Python 缓存
  - "dist/"           # 构建输出
  - "vectorstore/"    # 向量数据库 (可单独备份)
```

## 加密备份

敏感数据备份支持加密：

```yaml
encrypt: true
encryption:
  algorithm: aes-256-gcm
  key_source: env  # 从环境变量读取
  key_env: BACKUP_ENCRYPTION_KEY
```

## 恢复流程

### 单文件恢复
```
1. 列出包含该文件的备份版本
2. 选择版本
3. 恢复到指定位置
4. 验证文件完整性
```

### 全量恢复
```
1. 选择备份版本
2. 确认覆盖目标目录 (红线操作)
3. 执行恢复
4. 验证完整性 (checksum)
5. 报告恢复结果
```

## 相关文件

- 备份配置：`~/.openclaw/workspace/backup_config.yaml`
- 备份存储：`~/backups/`
- 操作日志：飞书日报文档

## 监控与告警

### 监控指标
- 备份成功率
- 备份大小趋势
- 备份耗时
- 存储空间使用率

### 告警条件
- 备份连续失败 3 次
- 备份大小异常 (±50%)
- 存储空间不足 (<10%)
- 备份耗时异常 (>2x 平均)

### 告警方式
- 飞书消息通知
- 本地日志记录
- 邮件通知 (可选)

## 审计日志

每次备份操作记录：
- 时间戳
- 备份任务名称
- 源路径
- 目标路径
- 备份类型 (full/incremental)
- 文件大小
- 文件数量
- 耗时
- 安全级别
- MAX 确认记录 (如适用)

日志同步至飞书日报文档。
