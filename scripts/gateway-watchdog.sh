#!/bin/bash
# gateway-watchdog.sh - Gateway 看门狗脚本
# 功能：每分钟检查 Gateway 状态，异常时自动重启

set -e

OPENCLAW_HOME="/home/admin/.openclaw"
LOG_FILE="$OPENCLAW_HOME/logs/gateway-watchdog.log"
GATEWAY_PORT="10676"

mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

check_gateway() {
    # 检查进程
    if ! pgrep -f "openclaw-gateway" > /dev/null; then
        log "❌ Gateway 进程不存在"
        return 1
    fi
    
    # 检查端口
    if ! netstat -tlnp 2>/dev/null | grep -q ":$GATEWAY_PORT" && \
       ! ss -tlnp 2>/dev/null | grep -q ":$GATEWAY_PORT"; then
        log "❌ Gateway 端口 $GATEWAY_PORT 未监听"
        return 1
    fi
    
    # 检查 WebSocket 连接
    if ! curl -s "http://127.0.0.1:$GATEWAY_PORT/" > /dev/null 2>&1; then
        log "❌ Gateway HTTP 检查失败"
        return 1
    fi
    
    log "✅ Gateway 状态正常"
    return 0
}

restart_gateway() {
    log "🔄 重启 Gateway..."
    
    # 停止旧进程
    systemctl --user stop openclaw-gateway 2>/dev/null || true
    sleep 2
    
    # 启动新进程
    systemctl --user start openclaw-gateway
    sleep 5
    
    if check_gateway; then
        log "✅ Gateway 重启成功"
        send_alert "Gateway 已自动恢复" "看门狗检测到异常并成功重启 Gateway"
        return 0
    else
        log "❌ Gateway 重启失败"
        send_alert "Gateway 重启失败" "看门狗检测到异常，重启失败，请手动检查"
        return 1
    fi
}

send_alert() {
    local title="$1"
    local message="$2"
    
    log "🚨 发送告警：$title"
    
    openclaw message send \
        --channel feishu \
        --account feishubot \
        --target "ou_b1597d6a325fa07fc1a1c9c4475c784e" \
        --message "🚨 [Gateway 告警] $title

$message

检查时间：$(date '+%Y-%m-%d %H:%M:%S')" \
        2>/dev/null || log "⚠️ 告警消息发送失败"
}

# 主流程
main() {
    log "========== 看门狗检查 =========="
    
    if ! check_gateway; then
        restart_gateway
    fi
    
    log "========== 看门狗检查结束 ==========
"
}

main "$@"
