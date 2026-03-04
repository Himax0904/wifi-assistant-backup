# Gateway 可靠性保障方案

**日期**: 2026-03-04  
**事件**: Gateway 服务中断 7 小时（13:04-20:22）  
**负责人**: 无牙

---

## 一、事件回顾

### 时间线

| 时间 | 事件 | 状态 |
|------|------|------|
| 13:04 | 最后一次正常消息处理 | ✅ 正常 |
| 13:04-20:22 | Gateway 无日志记录 | ❌ **服务中断** |
| 20:22:44 | Gateway 重启（用户手动） | ✅ 恢复 |
| 20:23:35 | 收到用户消息 | ✅ 正常 |
| 20:30 | 心跳检查发现 Cron 服务异常 | ⚠️ 告警 |

### 影响

- **中断时长**: 约 7 小时
- **影响范围**: 所有定时任务、消息处理
- **用户感知**: 无法收到回复和提醒

---

## 二、根因分析

### 直接原因

**Gateway 进程在 13:04-20:22 期间停止运行**

### 证据链

1. **Gateway 日志**：
   - 最后记录：13:04:56 `feishu: skipping duplicate message`
   - 重启记录：20:22:44 `listening on ws://0.0.0.0:10676`
   - 中断时长：7 小时 18 分钟

2. **心跳日志**：
   - 20:00:01 `❌ Cron 服务未启用`
   - 20:30:01 `❌ Cron 服务未启用`
   - 21:00:01 `❌ Cron 服务未启用`

3. **systemd 状态**：
   ```
   Runtime: running (pid 113630, state active)
   Service: systemd (enabled)
   ```

### 可能原因

| 原因 | 概率 | 说明 |
|------|------|------|
| Gateway 进程崩溃 | ⚠️ 高 | 内存泄漏/资源耗尽 |
| 系统重启 | ⚠️ 中 | 用户确认重启 |
| OOM Killer | ⚠️ 中 | 内存不足被系统杀掉 |
| 手动停止 | ⚠️ 低 | 无相关记录 |

---

## 三、预防方案

### 三层保障架构

```
┌─────────────────────────────────────────────────────────┐
│  第一层：systemd 自动重启（已配置 ✅）                   │
│  - 进程崩溃后自动重启                                   │
│  - 开机自启动                                           │
└─────────────────────┬───────────────────────────────────┘
                      ↓ 失败检测
┌─────────────────────────────────────────────────────────┐
│  第二层：看门狗脚本（新增 ✅）                           │
│  - 每分钟检查 Gateway 状态                               │
│  - 进程/端口/HTTP 三重检查                               │
│  - 异常时自动重启并告警                                 │
└─────────────────────┬───────────────────────────────────┘
                      ↓ 双重失败
┌─────────────────────────────────────────────────────────┐
│  第三层：心跳检查 + 告警（已配置 ✅）                    │
│  - 每 30 分钟检查 Cron 服务状态                           │
│  - 发现异常发送告警消息                                 │
│  - 用户手动介入                                         │
└─────────────────────────────────────────────────────────┘
```

### 方案一：systemd 自动重启 ✅

**配置文件**: `~/.config/systemd/user/openclaw-gateway.service`

**状态**:
```
Service: systemd (enabled)
File logs: /tmp/openclaw/openclaw-2026-03-04.log
```

**管理命令**:
```bash
# 查看状态
systemctl --user status openclaw-gateway

# 查看日志
journalctl --user -u openclaw-gateway -f

# 重启服务
systemctl --user restart openclaw-gateway
```

### 方案二：看门狗脚本 ✅

**脚本**: `workspace/scripts/gateway-watchdog.sh`

**功能**:
- 每分钟检查 Gateway 进程
- 检查端口监听状态
- 检查 HTTP 连接
- 异常时自动重启
- 发送告警消息

**安装**:
```bash
# 已添加到系统 crontab
* * * * * /home/admin/.openclaw/workspace/scripts/gateway-watchdog.sh
```

**检查命令**:
```bash
# 查看看门狗日志
tail -f /home/admin/.openclaw/logs/gateway-watchdog.log

# 手动测试
/home/admin/.openclaw/workspace/scripts/gateway-watchdog.sh
```

### 方案三：心跳检查 ✅

**脚本**: `workspace/scripts/cron-heartbeat.sh`

**频率**: 每 30 分钟

**功能**:
- 检查 Cron 服务状态
- 检查任务连续错误
- 发送告警消息

---

## 四、监控命令速查

### Gateway 状态

```bash
# 查看进程
ps aux | grep openclaw-gateway

# 查看端口
netstat -tlnp | grep 10676

# 查看 systemd 状态
systemctl --user status openclaw-gateway

# 查看日志
tail -f /tmp/openclaw/openclaw-*.log

# 查看 journalctl
journalctl --user -u openclaw-gateway -f
```

### 看门狗状态

```bash
# 查看日志
tail -f /home/admin/.openclaw/logs/gateway-watchdog.log

# 手动检查
/home/admin/.openclaw/workspace/scripts/gateway-watchdog.sh
```

### 心跳检查

```bash
# 查看日志
tail -f /home/admin/.openclaw/logs/cron-heartbeat.log

# 手动检查
/home/admin/.openclaw/workspace/scripts/cron-heartbeat.sh
```

### Crontab 配置

```bash
# 查看当前配置
crontab -l

# 编辑配置
crontab -e
```

---

## 五、告警响应

### 告警类型

| 告警 | 含义 | 响应 |
|------|------|------|
| Gateway 已自动恢复 | 看门狗检测到异常并成功重启 | 检查日志，确认原因 |
| Gateway 重启失败 | 看门狗重启失败 | 立即手动介入 |
| Cron 服务未启用 | Cron 调度器异常 | 检查 Gateway 状态 |
| 定时任务连续失败 | 任务执行异常 | 检查任务配置 |

### 响应流程

```
收到告警 → 检查 Gateway 状态 → 查看日志 → 定位原因 → 修复/重启
```

---

## 六、配置清单

| 文件 | 路径 | 用途 |
|------|------|------|
| Gateway 服务 | `~/.config/systemd/user/openclaw-gateway.service` | systemd 配置 |
| 看门狗脚本 | `workspace/scripts/gateway-watchdog.sh` | 自动监控 |
| 心跳脚本 | `workspace/scripts/cron-heartbeat.sh` | 定时检查 |
| Gateway 日志 | `/tmp/openclaw/openclaw-*.log` | 运行日志 |
| 看门狗日志 | `logs/gateway-watchdog.log` | 监控日志 |
| 心跳日志 | `logs/cron-heartbeat.log` | 检查日志 |

---

## 七、验证清单

- [x] systemd 服务已启用
- [x] 看门狗脚本已创建
- [x] 看门狗已添加到 crontab
- [x] 心跳检查已运行
- [ ] 验证看门狗自动重启功能
- [ ] 验证告警消息发送
- [ ] 压力测试（可选）

---

## 八、后续优化

### 短期（本周）
- [ ] 验证看门狗自动重启功能
- [ ] 添加内存/CPU 监控
- [ ] 优化告警频率（避免轰炸）

### 中期（本月）
- [ ] 添加 Gateway 性能监控
- [ ] 实现日志轮转
- [ ] 添加健康检查 API

### 长期（下季度）
- [ ] 高可用部署（多实例）
- [ ] 远程监控告警（短信/电话）
- [ ] 自动故障诊断

---

**报告完成时间**: 2026-03-04 21:10  
**下次检查时间**: 每分钟（看门狗）+ 每 30 分钟（心跳）
