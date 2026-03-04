---
name: feishu-media
description: 飞书媒体发送指南。支持发送本地图片、截图、网络图片到飞书。
metadata: {"clawdbot":{"emoji":"📸"}}
triggers:
  - 飞书
  - feishu
  - 发送图片
  - 发送文件
  - 发图
  - 截图
  - 照片
  - 图片
priority: 90
---

# 飞书媒体发送指南

## ⚠️ 重要：你有能力发送本地图片到飞书！

**使用 `openclaw message` 命令即可发送本地图片。**

---

## 📸 方案一：本地图片发送（已验证 ✅）

### 命令格式

```bash
openclaw message send \
  --channel feishu \
  --account feishubot \
  --target "ou_xxx" \
  --message "图片描述" \
  --media "/path/to/image.png"
```

### 示例

**发送本地图片**：
```bash
openclaw message send \
  --channel feishu \
  --account feishubot \
  --target "ou_b1597d6a325fa07fc1a1c9c9c4475c784e" \
  --message "这是你要的图片" \
  --media "/home/admin/.openclaw/workspace/test-image.png"
```

**发送网络图片**：
```bash
openclaw message send \
  --channel feishu \
  --account feishubot \
  --target "ou_xxx" \
  --message "网络图片" \
  --media "https://example.com/image.png"
```

---

## 🖥️ 方案二：浏览器截图 ✅ 已验证

### 使用 Chrome 无头模式截图

**命令格式**：
```bash
# 截取网页
google-chrome --headless --disable-gpu --screenshot=/path/to/output.png --window-size=1920,1080 https://example.com

# 移动到 workspace 目录（媒体访问限制）
cp /path/to/output.png /home/admin/.openclaw/workspace/screenshot.png

# 发送截图
openclaw message send \
  --channel feishu \
  --account feishubot \
  --target "ou_xxx" \
  --message "网页截图" \
  --media "/home/admin/.openclaw/workspace/screenshot.png"
```

### 验证结果
- ✅ 测试时间：2026-03-04 20:28
- ✅ 消息 ID: om_x100b55b6169ed4b0b4b9c571dadc35e
- ✅ 截图成功发送

---

## 📋 方案三：飞书云盘/云文档

### 上传图片到飞书云盘

1. 使用 `feishu_drive` 工具上传
2. 获取分享链接
3. 发送链接给用户

**示例**：
```bash
# 上传到云盘（需实现）
feishu_drive upload --path /path/to/image.png --folder "图片库"

# 发送链接
openclaw message send \
  --channel feishu \
  --account feishubot \
  --target "ou_xxx" \
  --message "图片已上传到云盘：https://xxx.feishu.cn/drive/xxx"
```

---

## 🎯 快速参考

| 方案 | 适用场景 | 命令 |
|------|---------|------|
| 本地图片 | 已有图片文件 | `openclaw message send --media` |
| 浏览器截图 | 网页截图 | `browser screenshot` + `message send` |
| 飞书云盘 | 大文件/长期存储 | `feishu_drive upload` |

---

## ⚠️ 注意事项

1. **图片格式**：支持 png, jpg, jpeg, gif, webp
2. **文件大小**：飞书限制单文件 100MB
3. **路径**：使用绝对路径
4. **账户**：必须指定 `--account feishubot`

---

## 测试验证

**测试命令**：
```bash
# 创建测试图片
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" | base64 -d > /tmp/test.png

# 发送测试
openclaw message send \
  --channel feishu \
  --account feishubot \
  --target "ou_xxx" \
  --message "📸 图片发送测试" \
  --media "/tmp/test.png"
```
