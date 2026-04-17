# MiniMax Monitor

macOS 菜单栏应用，实时显示 MiniMax API 使用量余额。

## 功能

- 菜单栏显示圆环图标，显示文本模型使用量
- 点击展开详情列表，显示所有模型的使用量
- 支持国际版和大陆版切换
- 自动定时刷新
- 绿色进度条直观展示使用比例

## 环境要求

- macOS 13.0+
- Xcode 15.0+

## 安装

1. 克隆项目到本地
2. 用 Xcode 打开 `MiniMaxMonitor.xcodeproj`
3. 修改 Bundle Identifier（如果需要打包）
4. 选择签名证书（推荐 "Sign to Run Locally" 用于开发）
5. 编译运行 (Cmd+R)

## 配置

1. 运行应用后，点击菜单栏的圆环图标
2. 点击设置按钮（齿轮图标）
3. 选择区域：
   - Global (minimax.io) - 国际版
   - 中国大陆 (minimaxi.com) - 大陆版
4. 输入 API Key（在 MiniMax 开放平台 → 接口密钥 获取）
5. 设置刷新间隔
6. 保存

## 开发

### 项目结构

```
MiniMaxMonitor/
├── Sources/MiniMaxMonitor/
│   ├── MiniMaxMonitorApp.swift  # 主程序入口
│   ├── ContentView.swift        # 菜单栏弹出界面
│   └── UsageManager.swift        # API 调用和数据处理
├── project.yml                  # XcodeGen 配置
└── MiniMaxMonitor.xcodeproj    # Xcode 项目
```

### 技术栈

- SwiftUI
- AppKit (菜单栏)
- URLSession (网络请求)

### 主要依赖

- 无外部依赖，纯 SwiftUI + AppKit

## 注意事项

- API Key 保存在 UserDefaults 中，仅本地存储
- 应用为菜单栏应用，不在 Dock 显示
- 刷新间隔默认为 60 秒

## 许可证

MIT License