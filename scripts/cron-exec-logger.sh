#!/bin/bash
# cron-exec-logger.sh - 定时任务执行日志记录脚本
# 功能：记录每次 cron 任务执行情况，用于审计和问题追溯

set -e

OPENCLAW_HOME="/home/admin/.openclaw"
CRON_JOBS_FILE="$OPENCLAW_HOME/cron/jobs.json"
EXEC_LOG_FILE="$OPENCLAW_HOME/logs/cron-execution.jsonl"
STATUS_LOG_FILE="$OPENCLAW_HOME/logs/cron-status.log"

mkdir -p "$(dirname "$EXEC_LOG_FILE")"

log_status() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$STATUS_LOG_FILE"
}

log_execution() {
    local job_id="$1"
    local job_name="$2"
    local status="$3"
    local timestamp_ms=$(date +%s%3N)
    
    # JSONL 格式记录
    echo "{\"timestamp_ms\":$timestamp_ms,\"job_id\":\"$job_id\",\"job_name\":\"$job_name\",\"status\":\"$status\"}" >> "$EXEC_LOG_FILE"
}

# 检查并记录任务状态
check_and_log() {
    if [ ! -f "$CRON_JOBS_FILE" ]; then
        log_status "❌ 任务文件不存在"
        return 1
    fi
    
    log_status "📋 执行状态检查"
    
    # 使用 openclaw cron runs 获取最新执行记录
    local runs
    runs=$(openclaw cron runs --limit 10 2>&1) || true
    
    if echo "$runs" | grep -q '"status": "success"'; then
        log_status "✅ 最近任务执行成功"
    elif echo "$runs" | grep -q '"status": "error"'; then
        log_status "❌ 最近任务执行失败"
        # 提取错误信息
        local error_msg
        error_msg=$(echo "$runs" | grep -o '"error": "[^"]*"' | head -1)
        log_status "错误：$error_msg"
    fi
    
    # 列出所有任务状态
    openclaw cron list 2>&1 | while read -r line; do
        log_status "任务：$line"
    done
}

# 主流程
main() {
    log_status "========== 执行日志记录开始 =========="
    
    check_and_log
    
    log_status "========== 执行日志记录结束 ==========
"
}

main "$@"
