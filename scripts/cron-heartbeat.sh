#!/bin/bash
# cron-heartbeat.sh - 定时任务心跳检查脚本
# 功能：每 30 分钟检查 cron 任务状态，发现异常自动告警

set -e

OPENCLAW_HOME="/home/admin/.openclaw"
CRON_JOBS_FILE="$OPENCLAW_HOME/cron/jobs.json"
LOG_FILE="$OPENCLAW_HOME/logs/cron-heartbeat.log"
ALERT_CHANNEL="feishu"
ALERT_TO="ou_b1597d6a325fa07fc1a1c9c4475c784e"

# 确保日志目录存在
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# 检查 cron 服务状态
check_cron_service() {
    local status
    status=$(openclaw cron status 2>&1)
    
    if echo "$status" | grep -q '"enabled": true'; then
        log "✅ Cron 服务正常运行"
        return 0
    else
        log "❌ Cron 服务未启用"
        send_alert "Cron 服务未启用" "$status"
        return 1
    fi
}

# 检查任务状态
check_jobs_status() {
    if [ ! -f "$CRON_JOBS_FILE" ]; then
        log "⚠️ 任务文件不存在：$CRON_JOBS_FILE"
        send_alert "任务文件丢失" "文件路径：$CRON_JOBS_FILE"
        return 1
    fi
    
    # 检查是否有任务
    local job_count
    job_count=$(cat "$CRON_JOBS_FILE" | grep -c '"id"' || echo "0")
    
    if [ "$job_count" -eq 0 ]; then
        log "⚠️ 当前无定时任务"
        return 0
    fi
    
    log "📋 检测到 $job_count 个定时任务"
    
    # 检查连续错误
    local error_count
    error_count=$(cat "$CRON_JOBS_FILE" | grep -c '"consecutiveErrors": [1-9]' || echo "0")
    
    if [ "$error_count" -gt 0 ]; then
        log "❌ 发现 $error_count 个任务有连续错误"
        send_alert "定时任务连续失败" "有 $error_count 个任务出现连续错误，请检查"
        return 1
    fi
    
    log "✅ 所有任务状态正常"
    return 0
}

# 发送告警
send_alert() {
    local title="$1"
    local message="$2"
    
    log "🚨 发送告警：$title"
    
    # 通过 openclaw message 发送
    openclaw message send \
        --channel "$ALERT_CHANNEL" \
        --to "$ALERT_TO" \
        --message "🚨 [定时任务告警] $title

$message

检查时间：$(date '+%Y-%m-%d %H:%M:%S')" \
        2>/dev/null || log "⚠️ 告警消息发送失败"
}

# 主流程
main() {
    log "========== 心跳检查开始 =========="
    
    local exit_code=0
    
    check_cron_service || exit_code=1
    check_jobs_status || exit_code=1
    
    if [ $exit_code -eq 0 ]; then
        log "✅ 心跳检查通过"
    else
        log "❌ 心跳检查发现问题"
    fi
    
    log "========== 心跳检查结束 ==========
"
    
    return $exit_code
}

main "$@"
