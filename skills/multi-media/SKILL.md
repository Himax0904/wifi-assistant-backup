---
name: multi-media
description: 多媒体处理技能。支持图像处理、音频处理、视频处理、格式转换。Use when: 需要图片压缩、格式转换、音频提取、视频剪辑、媒体文件处理。【储备技能，待 MAX 激活】
---

# Multi Media 技能

**状态**: ✅ 已激活  
**方向**: 多媒体处理  
**创建时间**: 2026-03-02  
**激活时间**: 2026-03-03

---

## 核心能力

### 1. 图像处理
- 格式转换 (JPG/PNG/WebP/GIF)
- 尺寸调整
- 压缩优化
- 水印添加
- 裁剪/旋转
- 滤镜效果

### 2. 音频处理
- 格式转换 (MP3/WAV/FLAC/M4A)
- 音频提取 (从视频)
- 音量调整
- 剪辑/合并
- 降噪处理

### 3. 视频处理
- 格式转换 (MP4/MOV/AVI/MKV)
- 尺寸调整
- 压缩优化
- 剪辑/裁剪
- 添加字幕
- 提取音频

### 4. 批量处理
- 批量格式转换
- 批量压缩
- 批量水印
- 队列处理

---

## 使用示例

### 示例 1: 图片压缩
```
压缩这张图片到 500KB 以内
→ 分析图片大小
→ 调整质量和尺寸
→ 输出压缩后图片
```

### 示例 2: 格式转换
```
把这张 PNG 转为 WebP 格式
→ 读取 PNG 文件
→ 转换为 WebP
→ 保存并返回
```

### 示例 3: 视频提取音频
```
从这个视频中提取音频
→ 读取视频文件
→ 提取音频轨道
→ 保存为 MP3
```

### 示例 4: 批量处理
```
把这个文件夹的所有图片转为 JPG
→ 扫描文件夹
→ 批量转换
→ 输出到新目录
```

---

## 配置示例

```yaml
# ~/.openclaw/workspace/media_config.yaml
multi_media:
  enabled: false  # 待激活
  image:
    default_format: webp
    quality: 85
    max_width: 1920
    max_height: 1080
  audio:
    default_format: mp3
    bitrate: 192k
  video:
    default_format: mp4
    codec: h264
    crf: 23
  output_dir: ~/media_output/
```

---

## 依赖工具

| 工具 | 用途 | 安装 |
|------|------|------|
| ffmpeg | 音视频处理 | apt install ffmpeg |
| imagemagick | 图像处理 | apt install imagemagick |
| optipng | PNG 优化 | apt install optipng |
| jpegoptim | JPEG 优化 | apt install jpegoptim |

---

**状态**: 🟡 储备中  
**激活条件**: MAX 发出"激活 multi-media 技能"
