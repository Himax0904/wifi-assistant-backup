#!/bin/bash
# 无牙助理迁移导入脚本
# 使用：./migration-import.sh <导出目录>

set -e

IMPORT_DIR="$1"
WORKSPACE=~/.openclaw/workspace

if [ -z "$IMPORT_DIR" ]; then
    echo "错误：请指定导入目录"
    echo "用法：$0 <导出目录>"
    exit 1
fi

if [ ! -d "$IMPORT_DIR" ]; then
    echo "错误：导入目录不存在：$IMPORT_DIR"
    exit 1
fi

echo "=== 无牙助理迁移导入 ==="
echo ""
echo "导入源：$IMPORT_DIR"
echo "目标：$WORKSPACE"
echo ""

# 备份现有工作区（如果存在）
if [ -d "$WORKSPACE" ] && [ "$(ls -A $WORKSPACE 2>/dev/null)" ]; then
    BACKUP_DIR="$WORKSPACE.backup.$(date +%Y%m%d_%H%M%S)"
    echo "⚠️  检测到现有工作区，备份到：$BACKUP_DIR"
    cp -r "$WORKSPACE" "$BACKUP_DIR"
    echo "  备份完成"
    echo ""
fi

# 创建工作区
mkdir -p "$WORKSPACE"
cd "$WORKSPACE"

# 导入核心文件
echo "[1/6] 导入核心文件..."
if [ -f "$IMPORT_DIR/SOUL.md" ]; then
    cp "$IMPORT_DIR"/*.md "$WORKSPACE/"
    echo "  ✅ 核心文件已导入"
else
    echo "  ⚠️  未找到核心文件"
fi

# 导入技能库
echo "[2/6] 导入技能库..."
if [ -d "$IMPORT_DIR/skills" ]; then
    if [ -d "$WORKSPACE/skills" ]; then
        echo "  ⚠️  现有技能库已备份"
    fi
    cp -r "$IMPORT_DIR/skills" "$WORKSPACE/"
    SKILL_COUNT=$(find "$WORKSPACE/skills" -name "SKILL.md" | wc -l)
    echo "  ✅ 技能库已导入 ($SKILL_COUNT 个技能)"
else
    echo "  ⚠️  未找到技能库"
fi

# 导入配置文件
echo "[3/6] 导入配置文件..."
if [ -f "$IMPORT_DIR/ssh_hosts.yaml" ]; then
    cp "$IMPORT_DIR"/*.yaml "$WORKSPACE/" 2>/dev/null || true
    cp "$IMPORT_DIR"/*.yml "$WORKSPACE/" 2>/dev/null || true
    echo "  ✅ 配置文件已导入"
else
    echo "  ℹ️  无配置文件"
fi

# 导入记忆目录
echo "[4/6] 导入记忆目录..."
if [ -d "$IMPORT_DIR/memory" ]; then
    cp -r "$IMPORT_DIR/memory" "$WORKSPACE/"
    echo "  ✅ 记忆目录已导入"
else
    echo "  ℹ️  无记忆目录"
fi

# 导入工作区数据
echo "[5/6] 导入工作区数据..."
for dir in test_data workflows visualizations knowledge_bases charts vectorstore reports; do
    if [ -d "$IMPORT_DIR/$dir" ]; then
        cp -r "$IMPORT_DIR/$dir" "$WORKSPACE/"
        echo "  ✅ $dir/"
    fi
done

# 导入工作区配置
echo "[6/6] 导入工作区配置..."
if [ -d "$IMPORT_DIR/.openclaw" ]; then
    mkdir -p "$WORKSPACE/.openclaw"
    cp -r "$IMPORT_DIR/.openclaw"/* "$WORKSPACE/.openclaw/" 2>/dev/null || true
    echo "  ✅ 工作区配置已导入"
else
    echo "  ℹ️  无工作区配置"
fi

# 设置权限
echo ""
echo "设置权限..."
chmod -R u+rw "$WORKSPACE"
chmod +x "$WORKSPACE/scripts/"*.sh 2>/dev/null || true

echo ""
echo "=== 导入完成 ==="
echo ""
echo "文件统计:"
echo "  技能数量：$(find "$WORKSPACE/skills" -name "SKILL.md" 2>/dev/null | wc -l)"
echo "  配置文件：$(ls "$WORKSPACE"/*.yaml 2>/dev/null | wc -l)"
echo "  总文件数：$(find "$WORKSPACE" -type f 2>/dev/null | wc -l)"
echo ""
echo "下一步:"
echo "  1. 验证导入：./scripts/migration-verify.sh"
echo "  2. 重启 OpenClaw: openclaw gateway restart"
echo ""

if [ -n "$BACKUP_DIR" ]; then
    echo "备份位置：$BACKUP_DIR"
    echo "如需恢复：cp -r $BACKUP_DIR/* $WORKSPACE/"
fi
