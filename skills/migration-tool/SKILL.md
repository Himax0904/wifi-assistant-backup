---
name: migration-tool
description: 迁移工具技能。提供 无牙助理技能库和本地数据的完整导出、导入、验证流程。Use when: 需要迁移助理到新环境、备份技能库、恢复数据、跨设备同步。
---

# Migration Tool 技能

## 概述

本技能提供完整的迁移方案，用于转移 无牙助理的技能库、配置文件、记忆数据到新环境。

**迁移内容**:
- 技能库 (`skills/`)
- 配置文件 (`*.yaml`, `*.json`)
- 记忆文件 (`MEMORY.md`, `memory/`)
- 身份文件 (`SOUL.md`, `IDENTITY.md`, `USER.md`)
- 工具配置 (`TOOLS.md`)
- 测试数据 (可选)

**数据量**: 约 500KB - 1MB

---

## 导出流程

### 步骤 1: 准备导出

```bash
# 进入工作区
cd ~/.openclaw/workspace

# 创建导出目录
mkdir -p ~/wuya-backup/$(date +%Y-%m-%d_%H-%M-%S)
EXPORT_DIR=~/wuya-backup/$(date +%Y-%m-%d_%H-%M-%S)
```

### 步骤 2: 运行导出脚本

```bash
# 执行导出脚本
./scripts/migration-export.sh $EXPORT_DIR
```

### 步骤 3: 验证导出

```bash
# 检查导出文件
ls -lh $EXPORT_DIR/

# 验证完整性
./scripts/migration-verify.sh $EXPORT_DIR
```

### 步骤 4: 传输导出文件

```bash
# 方式 1: SCP 传输
scp -r $EXPORT_DIR user@new-host:~/

# 方式 2: 压缩后传输
tar -czf ~/wuya-backup.tar.gz -C ~/ wuya-backup/

# 方式 3: 云存储同步
# 将 $EXPORT_DIR 同步到飞书云盘/其他云存储
```

---

## 导入流程

### 步骤 1: 准备新环境

```bash
# 确保 OpenClaw 已安装
openclaw --version

# 创建工作区
mkdir -p ~/.openclaw/workspace
cd ~/.openclaw/workspace
```

### 步骤 2: 运行导入脚本

```bash
# 从导出目录导入
./scripts/migration-import.sh /path/to/export/dir

# 或从压缩包导入
tar -xzf ~/wuya-backup.tar.gz -C ~/
./scripts/migration-import.sh ~/wuya-backup/$(date +%Y-%m-%d)
```

### 步骤 3: 验证导入

```bash
# 检查文件完整性
./scripts/migration-verify.sh ~/.openclaw/workspace

# 检查技能数量
ls -la skills/ | wc -l

# 检查配置文件
cat IDENTITY.md
```

### 步骤 4: 激活配置

```bash
# 重启 OpenClaw
openclaw gateway restart

# 或重新加载配置
openclaw reload
```

---

## 脚本详情

### migration-export.sh

```bash
#!/bin/bash
# 无牙助理迁移导出脚本

set -e

EXPORT_DIR="${1:-./wifi-export-$(date +%Y%m-%d_%H%M%S)}"

echo "=== 无牙助理迁移导出 ==="
echo "导出目录：$EXPORT_DIR"

# 创建导出目录
mkdir -p "$EXPORT_DIR"

# 导出核心文件
echo "导出核心文件..."
cp -r SOUL.md IDENTITY.md USER.md AGENTS.md TOOLS.md MEMORY.md "$EXPORT_DIR/"
cp -r HEARTBEAT.md BOOTSTRAP.md 2>/dev/null "$EXPORT_DIR/" || true

# 导出技能库
echo "导出技能库..."
cp -r skills/ "$EXPORT_DIR/"

# 导出配置文件
echo "导出配置文件..."
cp *.yaml *.yml *.json "$EXPORT_DIR/" 2>/dev/null || true

# 导出记忆目录
echo "导出记忆目录..."
cp -r memory/ "$EXPORT_DIR/" 2>/dev/null || true

# 导出工作区配置
echo "导出工作区配置..."
cp -r .openclaw/workspace-state.json "$EXPORT_DIR/" 2>/dev/null || true

# 创建导出清单
echo "创建导出清单..."
cat > "$EXPORT_DIR/EXPORT_MANIFEST.txt" << EOF
无牙助理迁移导出清单
导出时间：$(date)
主机名：$(hostname)
OpenClaw 版本：$(openclaw --version 2>/dev/null || echo "unknown")

文件列表:
$(find "$EXPORT_DIR" -type f | wc -l) 个文件
总大小：$(du -sh "$EXPORT_DIR" | cut -f1)

目录结构:
$(tree -L 2 "$EXPORT_DIR" 2>/dev/null || find "$EXPORT_DIR" -maxdepth 2 -type d)
EOF

# 创建压缩包
echo "创建压缩包..."
cd ~/
tar -czf "$EXPORT_DIR.tar.gz" "$(basename $EXPORT_DIR)"

echo ""
echo "=== 导出完成 ==="
echo "导出目录：$EXPORT_DIR"
echo "压缩包：$EXPORT_DIR.tar.gz"
echo "总大小：$(du -sh "$EXPORT_DIR.tar.gz" | cut -f1)"
```

### migration-import.sh

```bash
#!/bin/bash
# 无牙助理迁移导入脚本

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
echo "导入源：$IMPORT_DIR"
echo "目标：$WORKSPACE"

# 备份现有工作区（如果存在）
if [ -d "$WORKSPACE" ] && [ "$(ls -A $WORKSPACE)" ]; then
    BACKUP_DIR="$WORKSPACE.backup.$(date +%Y%m%d_%H%M%S)"
    echo "备份现有工作区到：$BACKUP_DIR"
    cp -r "$WORKSPACE" "$BACKUP_DIR"
fi

# 创建工作区
mkdir -p "$WORKSPACE"

# 导入核心文件
echo "导入核心文件..."
cp "$IMPORT_DIR"/*.md "$WORKSPACE/" 2>/dev/null || true

# 导入技能库
echo "导入技能库..."
if [ -d "$IMPORT_DIR/skills" ]; then
    cp -r "$IMPORT_DIR/skills" "$WORKSPACE/"
fi

# 导入配置文件
echo "导入配置文件..."
cp "$IMPORT_DIR"/*.yaml "$WORKSPACE/" 2>/dev/null || true
cp "$IMPORT_DIR"/*.yml "$WORKSPACE/" 2>/dev/null || true
cp "$IMPORT_DIR"/*.json "$WORKSPACE/" 2>/dev/null || true

# 导入记忆目录
echo "导入记忆目录..."
if [ -d "$IMPORT_DIR/memory" ]; then
    cp -r "$IMPORT_DIR/memory" "$WORKSPACE/"
fi

# 导入工作区配置
echo "导入工作区配置..."
if [ -f "$IMPORT_DIR/workspace-state.json" ]; then
    mkdir -p "$WORKSPACE/.openclaw"
    cp "$IMPORT_DIR/workspace-state.json" "$WORKSPACE/.openclaw/"
fi

# 设置权限
echo "设置权限..."
chmod -R u+rw "$WORKSPACE"

echo ""
echo "=== 导入完成 ==="
echo "请运行验证脚本：./scripts/migration-verify.sh $WORKSPACE"
```

### migration-verify.sh

```bash
#!/bin/bash
# 无牙助理迁移验证脚本

set -e

TARGET_DIR="${1:-~/.openclaw/workspace}"

echo "=== 无牙助理迁移验证 ==="
echo "验证目录：$TARGET_DIR"

ERRORS=0

# 验证核心文件
echo ""
echo "检查核心文件..."
for file in SOUL.md IDENTITY.md USER.md AGENTS.md MEMORY.md; do
    if [ -f "$TARGET_DIR/$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file (缺失)"
        ((ERRORS++))
    fi
done

# 验证技能库
echo ""
echo "检查技能库..."
if [ -d "$TARGET_DIR/skills" ]; then
    SKILL_COUNT=$(find "$TARGET_DIR/skills" -name "SKILL.md" | wc -l)
    echo "  ✅ 技能目录存在"
    echo "  📊 技能数量：$SKILL_COUNT"
else
    echo "  ❌ 技能目录缺失"
    ((ERRORS++))
fi

# 验证配置文件
echo ""
echo "检查配置文件..."
for file in ssh_hosts.yaml backup_config.yaml analytics_config.yaml; do
    if [ -f "$TARGET_DIR/$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ⚠️  $file (可选)"
    fi
done

# 验证记忆文件
echo ""
echo "检查记忆文件..."
if [ -f "$TARGET_DIR/MEMORY.md" ]; then
    LINES=$(wc -l < "$TARGET_DIR/MEMORY.md")
    echo "  ✅ MEMORY.md ($LINES 行)"
else
    echo "  ⚠️  MEMORY.md (可重建)"
fi

# 验证 TOOLS.md
echo ""
echo "检查工具配置..."
if [ -f "$TARGET_DIR/TOOLS.md" ]; then
    echo "  ✅ TOOLS.md"
else
    echo "  ⚠️  TOOLS.md (可重建)"
fi

# 总结
echo ""
echo "=== 验证总结 ==="
if [ $ERRORS -eq 0 ]; then
    echo "✅ 验证通过 - 所有核心文件完整"
    exit 0
else
    echo "❌ 验证失败 - $ERRORS 个错误"
    exit 1
fi
```

---

## 快速迁移命令

### 一键导出
```bash
cd ~/.openclaw/workspace
bash <(curl -s https://raw.githubusercontent.com/.../migration-export.sh) ~/wuya-backup
```

### 一键导入
```bash
cd ~/.openclaw/workspace
bash <(curl -s https://raw.githubusercontent.com/.../migration-import.sh) ~/wuya-backup
```

### 一键验证
```bash
bash <(curl -s https://raw.githubusercontent.com/.../migration-verify.sh) ~/.openclaw/workspace
```

---

## 迁移清单

### 必须迁移
- [ ] SOUL.md (人格设定)
- [ ] IDENTITY.md (身份配置)
- [ ] USER.md (用户信息)
- [ ] AGENTS.md (工作区规则)
- [ ] MEMORY.md (长期记忆)
- [ ] skills/ (技能库)
- [ ] TOOLS.md (工具配置)

### 建议迁移
- [ ] memory/ (日常记忆)
- [ ] *.yaml (配置文件)
- [ ] HEARTBEAT.md (心跳配置)
- [ ] workspace-state.json (工作区状态)

### 可选迁移
- [ ] test_data/ (测试数据)
- [ ] charts/ (图表输出)
- [ ] vectorstore/ (向量索引)
- [ ] 临时文件

---

## 故障排除

### 问题 1: 导入后技能不生效

**解决**:
```bash
# 重启 OpenClaw
openclaw gateway restart

# 检查技能目录权限
chmod -R 755 ~/.openclaw/workspace/skills/
```

### 问题 2: 配置文件冲突

**解决**:
```bash
# 手动检查配置差异
diff ~/.openclaw/workspace/ssh_hosts.yaml.backup ~/.openclaw/workspace/ssh_hosts.yaml

# 合并配置或选择其一
```

### 问题 3: 记忆文件丢失

**解决**:
```bash
# 从备份恢复
cp ~/.openclaw/workspace.backup/MEMORY.md ~/.openclaw/workspace/

# 或重建空文件
echo "# Long-Term Memory" > ~/.openclaw/workspace/MEMORY.md
```

---

## 安全注意事项

1. **敏感数据**: 检查配置文件中是否包含密码、密钥等敏感信息
2. **SSH 密钥**: `~/.ssh/` 目录需要单独安全传输
3. **飞书 Token**: 如配置中包含 API token，建议重新生成
4. **备份原数据**: 导入前务必备份现有工作区

---

## 版本兼容性

| OpenClaw 版本 | 迁移支持 | 备注 |
|--------------|----------|------|
| v1.0+ | ✅ 完全支持 | - |
| v0.9 | ✅ 支持 | 可能需要手动调整配置 |
| v0.8 及以下 | ⚠️ 部分支持 | 建议升级后迁移 |

---

## 相关文件

- 导出脚本：`scripts/migration-export.sh`
- 导入脚本：`scripts/migration-import.sh`
- 验证脚本：`scripts/migration-verify.sh`
- 本技能：`skills/migration-tool/SKILL.md`

---

**创建时间**: 2026-03-02 11:45  
**状态**: 完成
