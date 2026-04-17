# MiniMax Monitor

macOS 菜单栏应用，实时显示 MiniMax API 使用量余额。

## GitHub

https://github.com/Mibslee/MiniMaxMonitor

## 功能

- 菜单栏圆环图标显示文本模型使用量
- 点击展开详情列表，按剩余量排序
- 支持国际版 (minimax.io) 和大陆版 (minimaxi.com)
- 自动定时刷新（可配置间隔）
- 绿色进度条直观展示使用比例
- 深色/浅色模式自动适配
- 详细的网络错误提示

## 环境要求

- macOS 13.0+
- Xcode 15.0+

## 安装

1. 克隆项目：`git clone https://github.com/Mibslee/MiniMaxMonitor.git`
2. 用 Xcode 打开 `MiniMaxMonitor.xcodeproj`
3. 编译运行 (Cmd+R)

## 配置

1. 运行应用后，点击菜单栏圆环图标
2. 点击设置按钮（齿轮图标）
3. 选择区域：Global 或 中国大陆
4. 输入 API Key
5. 设置刷新间隔，保存

## 项目结构

```
Sources/MiniMaxMonitor/
├── MiniMaxMonitorApp.swift  # 菜单栏图标、弹出逻辑
├── ContentView.swift        # UI 界面
└── UsageManager.swift      # API 调用、数据处理
```

## 技术栈

- SwiftUI + AppKit
- Native macOS theming (dark/light mode)
- URLSession

## 隐私说明

- API Key 存储在本地 UserDefaults
- 仅用于查询套餐余额，不上传任何数据

## App Store 上架

### 1. 注册 Bundle ID
https://developer.apple.com/account/resources/identifiers/list

### 2. 创建 App Store 记录
https://appstoreconnect.apple.com

### 3. 准备截图
需要 macOS 应用截图（可用 Cmd+Shift+4 截取）

### 4. 上传
Xcode → Product → Archive → Distribute App → App Store Connect

### 5. 提交审核

## 许可证

MIT License