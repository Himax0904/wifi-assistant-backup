---
name: workflow-automation
description: 自动化工作流技能。支持事件监听、条件判断、多步骤流程。Use when: 需要配置"当 X 发生时自动做 Y"的自动化任务、定时触发工作流、多系统联动操作。
---

# Workflow Automation 技能

## 安全属性

| 级别 | 操作类型 | 执行方式 |
|------|----------|----------|
| 🔴 红线 | 支付/转账授权、设备控制、对外群发消息 | 必须 MAX 明确确认，无确认不执行 |
| 🟡 黄线 | 对外沟通 (邮件/消息)、文件删除、隐私数据访问 | 先问询 MAX，确认后执行 |
| 🟢 绿线 | 日程查询、文件整理、数据读取、内部通知 | 直接执行，事后简报 |

## 核心能力

### 1. 触发器 (Triggers)
- **定时触发**：cron 表达式配置
- **事件触发**：监听邮件、日历、消息事件
- ** webhook 触发**：接收外部 HTTP 回调

### 2. 动作 (Actions)
- 发送消息 (飞书/微信/邮件)
- 读写文件/文档
- 调用 API
- 执行 shell 命令

### 3. 条件判断
- 支持 if/else 逻辑
- 支持数据过滤
- 支持多分支流程

## 使用示例

### 示例 1：每日早报
```
当 每天 09:00 → 读取昨日任务 → 生成简报 → 发送飞书
```

### 示例 2：邮件提醒
```
当 收到重要邮件 → 检查发件人 → 发送飞书通知
```

### 示例 3：日历提醒
```
当 会议前 30 分钟 → 读取会议信息 → 发送提醒消息
```

## 配置格式

工作流配置文件位于 `~/.openclaw/workspace/workflows/`，YAML 格式：

```yaml
name: daily-report
trigger:
  type: cron
  expression: "0 9 * * *"
actions:
  - type: read_tasks
    source: yesterday
  - type: generate_report
    format: markdown
  - type: send_message
    channel: feishu
    safety_level: green
```

## 安全执行流程

1. 解析工作流配置
2. 检查每个 action 的 safety_level
3. 🔴 红线操作 → 暂停，请求 MAX 确认
4. 🟡 黄线操作 → 暂停，请求 MAX 确认
5. 🟢 绿线操作 → 直接执行
6. 记录执行日志到飞书日报

## 相关文件

- 工作流配置目录：`~/.openclaw/workspace/workflows/`
- 执行日志：飞书日报文档
- 安全策略：`IDENTITY.md`
