#!/bin/bash
# 无牙助理迁移导出脚本
# 使用：./migration-export.sh <导出目录>

set -e

EXPORT_DIR="${1:-~/wifi-backup/$(date +%Y-%m-%d_%H-%M-%S)}"

echo "=== 无牙助理迁移导出 ==="
echo "导出目录：$EXPORT_DIR"
echo ""

# 创建导出目录
mkdir -p "$EXPORT_DIR"

# 导出核心文件
echo "[1/7] 导出核心文件..."
cp SOUL.md IDENTITY.md USER.md AGENTS.md TOOLS.md MEMORY.md "$EXPORT_DIR/" 2>/dev/null || true
cp HEARTBEAT.md BOOTSTRAP.md 2>/dev/null "$EXPORT_DIR/" || true

# 导出技能库
echo "[2/7] 导出技能库..."
if [ -d "skills" ]; then
    cp -r skills "$EXPORT_DIR/"
    SKILL_COUNT=$(find "$EXPORT_DIR/skills" -name "SKILL.md" | wc -l)
    echo "  技能数量：$SKILL_COUNT"
fi

# 导出配置文件
echo "[3/7] 导出配置文件..."
cp *.yaml *.yml 2>/dev/null "$EXPORT_DIR/" || true
echo "  配置文件：$(ls *.yaml *.yml 2>/dev/null | wc -l) 个"

# 导出记忆目录
echo "[4/7] 导出记忆目录..."
if [ -d "memory" ]; then
    cp -r memory "$EXPORT_DIR/"
    echo "  记忆文件：$(find "$EXPORT_DIR/memory" -name "*.md" | wc -l) 个"
else
    echo "  无记忆目录"
fi

# 导出测试和工作区数据
echo "[5/7] 导出工作区数据..."
for dir in test_data workflows visualizations knowledge_bases charts vectorstore reports scripts; do
    if [ -d "$dir" ]; then
        cp -r "$dir" "$EXPORT_DIR/"
    fi
done

# 创建工作区状态备份
echo "[6/7] 导出工作区状态..."
if [ -d ".openclaw" ]; then
    cp -r .openclaw "$EXPORT_DIR/" 2>/dev/null || true
fi

# 创建导出清单
echo "[7/7] 创建导出清单..."
cat > "$EXPORT_DIR/EXPORT_MANIFEST.txt" << EOF
无牙助理迁移导出清单
========================
导出时间：$(date)
主机名：$(hostname)
OpenClaw 版本：$(openclaw --version 2>/dev/null || echo "unknown")

文件统计:
- 总文件数：$(find "$EXPORT_DIR" -type f | wc -l)
- 技能数量：$(find "$EXPORT_DIR/skills" -name "SKILL.md" 2>/dev/null | wc -l)
- 配置文件：$(ls "$EXPORT_DIR"/*.yaml "$EXPORT_DIR"/*.yml 2>/dev/null | wc -l)
- 总大小：$(du -sh "$EXPORT_DIR" | cut -f1)

目录结构:
$(find "$EXPORT_DIR" -maxdepth 2 -type d | sort)

核心文件:
$(ls "$EXPORT_DIR"/*.md 2>/dev/null | xargs -I {} basename {})

配置文件:
$(ls "$EXPORT_DIR"/*.yaml "$EXPORT_DIR"/*.yml 2>/dev/null | xargs -I {} basename {})
EOF

# 创建压缩包
echo ""
echo "创建压缩包..."
cd "$(dirname $EXPORT_DIR)"
tar -czf "$(basename $EXPORT_DIR).tar.gz" "$(basename $EXPORT_DIR)"

echo ""
echo "=== 导出完成 ==="
echo ""
echo "导出目录：$EXPORT_DIR"
echo "压缩包：$EXPORT_DIR.tar.gz"
echo "总大小：$(du -h "$EXPORT_DIR.tar.gz" | cut -f1)"
echo ""
echo "传输建议:"
echo "  SCP:  scp -r $EXPORT_DIR user@new-host:~/"
echo "  压缩：tar -czf wifi-backup.tar.gz $(basename $EXPORT_DIR)"
echo ""
echo "验证命令:"
echo "  ./scripts/migration-verify.sh $EXPORT_DIR"
