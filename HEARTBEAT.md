# HEARTBEAT.md - 定时任务检查

## 定时检查任务（由主会话心跳触发）

### 每 4 小时检查（每日 6 次）
- [ ] 检查 cron 服务状态：`openclaw cron status`
- [ ] 检查任务执行记录：`openclaw cron runs --limit 5`
- [ ] 验证最近 24 小时是否有失败任务
- [ ] 发现异常立即告警

### 每日 20:00 检查
- [ ] 执行日志归档
- [ ] 清理 7 天前日志
- [ ] 生成日报摘要

---

## 检查命令速查

```bash
# 查看 cron 状态
openclaw cron status

# 查看任务列表
openclaw cron list

# 查看执行历史
openclaw cron runs --limit 10

# 查看特定任务执行记录
openclaw cron runs --id <job-id> --limit 5

# 手动触发心跳检查
/home/admin/.openclaw/workspace/scripts/cron-heartbeat.sh

# 同步系统 cron 备份
/home/admin/.openclaw/workspace/scripts/cron-backup-sync.sh

# 执行日志记录
/home/admin/.openclaw/workspace/scripts/cron-exec-logger.sh
```

---

**配置位置：**
- 任务存储：`~/.openclaw/cron/jobs.json`
- 执行日志：`~/.openclaw/logs/cron-execution.jsonl`
- 心跳日志：`~/.openclaw/logs/cron-heartbeat.log`
- 系统 crontab: `crontab -l`
