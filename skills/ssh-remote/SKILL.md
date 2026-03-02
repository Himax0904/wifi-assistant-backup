---
name: ssh-remote
description: SSH 远程服务器管理技能。支持 SSH 连接管理、远程命令执行、文件传输、服务监控。Use when: 需要管理云服务器/VPS/家庭服务器、执行远程命令、查看日志、文件传输、服务状态检查。
---

# SSH Remote 技能

## 安全属性

| 级别 | 操作类型 | 执行方式 |
|------|----------|----------|
| 🔴 红线 | 删除/格式化文件、重启生产服务器、修改系统配置、执行 rm -rf | 必须 MAX 明确确认，无确认不执行 |
| 🟡 黄线 | 执行未知命令、访问敏感目录 (/etc, /root)、安装软件、修改服务 | 先问询 MAX，确认后执行 |
| 🟢 绿线 | 查看日志、状态检查 (df, top, ps)、文件读取、服务状态查询 | 直接执行，事后简报 |

## 核心能力

### 1. SSH 连接管理
- 多主机配置（支持命名别名）
- 密钥认证（推荐）/密码认证
- 连接池管理（复用连接）
- 超时与重试机制

### 2. 远程命令执行
- 安全沙箱（命令白名单）
- 命令审计日志
- 输出捕获与解析
- 后台任务支持

### 3. 文件传输
- SCP 上传/下载
- SFTP 文件操作
- 增量传输（大文件）
- 传输进度跟踪

### 4. 服务监控
- CPU/内存/磁盘使用率
- 服务状态检查 (systemd, docker)
- 日志实时查看
- 告警通知

## 配置格式

主机配置位于 `~/.openclaw/workspace/ssh_hosts.yaml`：

```yaml
hosts:
  - name: home-server
    host: 192.168.1.100
    user: admin
    port: 22
    auth: key
    key_path: ~/.ssh/id_rsa
    safety_level: green
    tags: [local, nas]
    
  - name: vps-prod
    host: x.x.x.x
    user: root
    port: 22
    auth: key
    key_path: ~/.ssh/vps_key
    safety_level: yellow
    tags: [prod, web]
    
  - name: dev-server
    host: y.y.y.y
    user: deploy
    port: 22
    auth: password
    safety_level: green
    tags: [dev, test]

# 命令白名单 (绿线操作)
green_commands:
  - "df -h"
  - "free -m"
  - "top -bn1"
  - "ps aux"
  - "systemctl status *"
  - "docker ps"
  - "tail -f *"
  - "cat *"
  - "ls -la"
  - "uptime"

# 命令黑名单 (永远禁止)
blacklist_commands:
  - "rm -rf /"
  - "mkfs.*"
  - "dd if=/dev/zero"
  - ":(){:|:&};:"
  - "chmod -R 777 /"
```

## 使用示例

### 示例 1: 查看服务器状态 (绿线)
```
检查 home-server 的磁盘使用率
→ 执行 "df -h"
→ 返回结果
```

### 示例 2: 查看服务日志 (绿线)
```
查看 vps-prod 的 nginx 错误日志
→ 执行 "tail -100 /var/log/nginx/error.log"
→ 返回日志内容
```

### 示例 3: 重启开发服务 (黄线)
```
重启 dev-server 的 nginx 服务
→ 问询 MAX 确认
→ 执行 "sudo systemctl restart nginx"
→ 验证服务状态
```

### 示例 4: 删除文件 (红线)
```
删除 prod 服务器的旧备份
→ 请求 MAX 明确确认
→ 确认后执行 "rm /path/to/backup"
→ 记录操作日志
```

## 安全执行流程

1. 解析用户请求，识别目标主机和命令
2. 检查主机 safety_level
3. 检查命令类型 (白名单/黑名单/未知)
4. 🔴 红线操作 → 暂停，请求 MAX 明确确认
5. 🟡 黄线操作 → 暂停，问询 MAX
6. 🟢 绿线操作 → 直接执行
7. 执行命令，捕获输出
8. 记录操作日志到飞书日报

## 命令分类

### 绿线命令 (直接执行)
```bash
# 系统状态
df -h, free -m, uptime, top -bn1

# 进程查看
ps aux, pgrep *, pidof *

# 服务状态
systemctl status *, service * status

# Docker
docker ps, docker stats, docker logs *

# 文件操作
ls, cat, head, tail, wc, find (只读)

# 网络
netstat -tulpn, ss -tulpn, curl *, wget *
```

### 黄线命令 (先问询)
```bash
# 服务管理
systemctl start/stop/restart *, service * start/stop/restart

# 软件安装
apt install *, yum install *, pip install *, npm install *

# 文件修改
chmod *, chown *, mv *, cp *, mkdir *, rm (非系统目录)

# Docker 操作
docker start/stop/restart/rm *, docker exec *

# 配置修改
vi *, nano *, sed -i *, echo * >> *
```

### 红线命令 (必须确认)
```bash
# 危险删除
rm -rf *, especially /etc, /root, /var, /home

# 格式化
mkfs.*, fdisk *

# 系统重启
reboot, shutdown *, systemctl reboot/poweroff

# 权限修改
chmod -R 777 *, chown -R root:root *

# 数据库操作
DROP DATABASE, TRUNCATE *, DELETE FROM * (without WHERE)
```

## 相关文件

- 主机配置：`~/.openclaw/workspace/ssh_hosts.yaml`
- 操作日志：飞书日报文档
- SSH 密钥：`~/.ssh/` (用户管理)

## 错误处理

| 错误类型 | 处理方式 |
|----------|----------|
| 连接超时 | 重试 3 次，每次间隔 5 秒 |
| 认证失败 | 报告 MAX，不重试 |
| 命令执行失败 | 返回错误信息，分析原因 |
| 安全策略拦截 | 记录拦截日志，报告 MAX |

## 审计日志

每次 SSH 操作记录以下信息：
- 时间戳
- 目标主机
- 执行命令
- 安全级别
- 执行结果
- MAX 确认记录 (如适用)

日志同步至飞书日报文档。
