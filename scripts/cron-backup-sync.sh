#!/bin/bash
# cron-backup-sync.sh - 定时任务系统 cron 备份脚本
# 功能：将关键 OpenClaw cron 任务同步到系统 crontab 作为兜底

set -e

OPENCLAW_HOME="/home/admin/.openclaw"
CRON_JOBS_FILE="$OPENCLAW_HOME/cron/jobs.json"
BACKUP_CRON_FILE="$OPENCLAW_HOME/cron/system-backup.cron"
LOG_FILE="$OPENCLAW_HOME/logs/cron-backup.log"
OPENCLAW_BIN="/usr/local/bin/openclaw"

mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# 从 jobs.json 提取关键任务并生成系统 cron 格式
generate_system_cron() {
    if [ ! -f "$CRON_JOBS_FILE" ]; then
        log "⚠️ 任务文件不存在"
        return 1
    fi
    
    log "📝 生成系统 cron 备份配置"
    
    # 生成备份文件头
    cat > "$BACKUP_CRON_FILE" << 'HEADER'
# OpenClaw Cron Backup - 系统 crontab 兜底配置
# 由 cron-backup-sync.sh 自动生成
# 不要手动编辑此文件

# 环境变量
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin
OPENCLAW_HOME=/home/admin/.openclaw

HEADER

    # 添加心跳检查任务（每 30 分钟）
    echo "*/30 * * * * $OPENCLAW_HOME/workspace/scripts/cron-heartbeat.sh >> $LOG_FILE 2>&1" >> "$BACKUP_CRON_FILE"
    
    # 添加日志清理任务（每天凌晨 3 点）
    echo "0 3 * * * find $OPENCLAW_HOME/logs -name '*.log' -mtime +7 -delete >> /dev/null 2>&1" >> "$BACKUP_CRON_FILE"
    
    log "✅ 系统 cron 备份配置已生成：$BACKUP_CRON_FILE"
    cat "$BACKUP_CRON_FILE"
}

# 安装到系统 crontab
install_to_system_cron() {
    log "📥 安装系统 cron 配置"
    
    # 备份当前 crontab
    crontab -l > "$OPENCLAW_HOME/cron/user-cron.bak" 2>/dev/null || true
    
    # 合并配置
    if [ -f "$BACKUP_CRON_FILE" ]; then
        # 移除旧的 OpenClaw 配置（如果有）
        grep -v "OpenClaw Cron Backup" "$OPENCLAW_HOME/cron/user-cron.bak" 2>/dev/null | grep -v "cron-heartbeat.sh" | grep -v "cron-backup.log" > "$OPENCLAW_HOME/cron/user-cron.clean" 2>/dev/null || true
        
        # 合并新配置
        cat "$OPENCLAW_HOME/cron/user-cron.clean" "$BACKUP_CRON_FILE" > "$OPENCLAW_HOME/cron/user-cron.merged" 2>/dev/null || cat "$BACKUP_CRON_FILE" > "$OPENCLAW_HOME/cron/user-cron.merged"
        
        # 安装
        crontab "$OPENCLAW_HOME/cron/user-cron.merged"
        
        log "✅ 系统 crontab 已更新"
        crontab -l | tail -10
    else
        log "❌ 备份文件不存在，跳过安装"
        return 1
    fi
}

# 主流程
main() {
    log "========== Cron 备份同步开始 =========="
    
    generate_system_cron
    install_to_system_cron
    
    log "========== Cron 备份同步结束 ==========
"
}

main "$@"
