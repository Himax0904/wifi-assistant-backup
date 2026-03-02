#!/bin/bash
# Wi-Fi 助理迁移验证脚本
# 使用：./migration-verify.sh [验证目录]

set -e

TARGET_DIR="${1:-~/.openclaw/workspace}"

echo "=== Wi-Fi 助理迁移验证 ==="
echo "验证目录：$TARGET_DIR"
echo ""

ERRORS=0
WARNINGS=0

# 验证核心文件
echo "📋 检查核心文件..."
for file in SOUL.md IDENTITY.md USER.md AGENTS.md MEMORY.md; do
    if [ -f "$TARGET_DIR/$file" ]; then
        LINES=$(wc -l < "$TARGET_DIR/$file")
        echo "  ✅ $file ($LINES 行)"
    else
        echo "  ❌ $file (缺失)"
        ((ERRORS++))
    fi
done

# 验证可选核心文件
for file in HEARTBEAT.md TOOLS.md IDENTITY.md; do
    if [ -f "$TARGET_DIR/$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ⚠️  $file (可选)"
        ((WARNINGS++))
    fi
done

# 验证技能库
echo ""
echo "📚 检查技能库..."
if [ -d "$TARGET_DIR/skills" ]; then
    SKILL_COUNT=$(find "$TARGET_DIR/skills" -name "SKILL.md" | wc -l)
    echo "  ✅ 技能目录存在"
    echo "  📊 技能数量：$SKILL_COUNT"
    
    if [ $SKILL_COUNT -lt 5 ]; then
        echo "  ⚠️  技能数量较少，可能迁移不完整"
        ((WARNINGS++))
    fi
else
    echo "  ❌ 技能目录缺失"
    ((ERRORS++))
fi

# 验证关键技能
echo ""
echo "🔧 检查关键技能..."
KEY_SKILLS="ssh-remote auto-backup knowledge-analytics workflow-automation data-visualization local-rag"
for skill in $KEY_SKILLS; do
    if [ -f "$TARGET_DIR/skills/$skill/SKILL.md" ]; then
        echo "  ✅ $skill"
    else
        echo "  ℹ️  $skill (未安装)"
    fi
done

# 验证配置文件
echo ""
echo "⚙️  检查配置文件..."
CONFIG_FILES="ssh_hosts.yaml backup_config.yaml analytics_config.yaml"
for file in $CONFIG_FILES; do
    if [ -f "$TARGET_DIR/$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ⚠️  $file (可选)"
        ((WARNINGS++))
    fi
done

# 验证记忆文件
echo ""
echo "📝 检查记忆文件..."
if [ -f "$TARGET_DIR/MEMORY.md" ]; then
    LINES=$(wc -l < "$TARGET_DIR/MEMORY.md")
    echo "  ✅ MEMORY.md ($LINES 行)"
else
    echo "  ⚠️  MEMORY.md (可重建)"
    ((WARNINGS++))
fi

if [ -d "$TARGET_DIR/memory" ]; then
    MEMORY_FILES=$(find "$TARGET_DIR/memory" -name "*.md" | wc -l)
    echo "  ✅ memory/ 目录 ($MEMORY_FILES 个文件)"
else
    echo "  ℹ️  memory/ 目录 (可选)"
fi

# 验证脚本文件
echo ""
echo "🔧 检查脚本文件..."
if [ -d "$TARGET_DIR/scripts" ]; then
    SCRIPT_COUNT=$(find "$TARGET_DIR/scripts" -name "*.sh" | wc -l)
    echo "  ✅ scripts/ 目录 ($SCRIPT_COUNT 个脚本)"
    
    # 检查脚本可执行权限
    for script in migration-export.sh migration-import.sh migration-verify.sh; do
        if [ -x "$TARGET_DIR/scripts/$script" ]; then
            echo "    ✅ $script (可执行)"
        elif [ -f "$TARGET_DIR/scripts/$script" ]; then
            echo "    ⚠️  $script (需设置执行权限)"
            ((WARNINGS++))
        fi
    done
else
    echo "  ⚠️  scripts/ 目录缺失"
    ((WARNINGS++))
fi

# 验证工作区数据
echo ""
echo "📁 检查工作区数据..."
for dir in test_data workflows visualizations knowledge_bases; do
    if [ -d "$TARGET_DIR/$dir" ]; then
        FILE_COUNT=$(find "$TARGET_DIR/$dir" -type f | wc -l)
        echo "  ✅ $dir/ ($FILE_COUNT 个文件)"
    else
        echo "  ℹ️  $dir/ (可选)"
    fi
done

# 验证总文件数和大小
echo ""
echo "📊 总体统计..."
TOTAL_FILES=$(find "$TARGET_DIR" -type f 2>/dev/null | wc -l)
TOTAL_SIZE=$(du -sh "$TARGET_DIR" 2>/dev/null | cut -f1)
echo "  总文件数：$TOTAL_FILES"
echo "  总大小：$TOTAL_SIZE"

# 总结
echo ""
echo "=== 验证总结 ==="
echo "错误数：$ERRORS"
echo "警告数：$WARNINGS"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo "✅ 验证通过 - 所有核心文件完整"
    echo ""
    echo "下一步:"
    echo "  1. 重启 OpenClaw: openclaw gateway restart"
    echo "  2. 测试技能：与助理对话验证功能"
    exit 0
else
    echo "❌ 验证失败 - $ERRORS 个错误"
    echo ""
    echo "需要修复:"
    echo "  请检查导出文件是否完整，或重新导出"
    exit 1
fi
