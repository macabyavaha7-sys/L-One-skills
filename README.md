# L-One Skills

这是 L-One 技能注册表的 GitHub Pages 发布仓库。

## 在线地址

启用 GitHub Pages 后，网页地址应为：

```text
https://macabyavaha7-sys.github.io/L-One-skills/
```

如果 GitHub Pages 尚未启用，请在仓库页面进入：

```text
Settings -> Pages -> Build and deployment
Source: Deploy from a branch
Branch: main
Folder: / root
```

保存后等待几分钟，再访问上面的地址。

## 更新方式

本仓库首页文件是 `index.html`。它由本地技能注册表源文件同步而来：

```text
E:\L-One知识库\L-One知识库\具体有用的技能库\codex-video-tools-下载1-2026-05-06\07-skill-registry\skill-registry.html
```

以后新增 skill、Prompt 或 AI 技巧后，先更新本地技能注册表，再运行：

```powershell
.\scripts\publish-skill-registry.ps1
```

脚本会把本地最新版复制为 `index.html`，提交并推送到 GitHub。GitHub Pages 会在推送后自动发布最新版。
