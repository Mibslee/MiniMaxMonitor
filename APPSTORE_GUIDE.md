# App Store 上架完全指南

## 你需要准备的

### 1. Apple 开发者账号（必须）
- 地址：https://developer.apple.com/programs/
- 费用：¥688/年
- 用你的 Apple ID 注册并支付年费

### 2. App Store Connect 账号
- 地址：https://appstoreconnect.apple.com
- 用你的 Apple ID 登录

---

## 我已准备好的 ✅

- Bundle ID: `com.minimax.monitor`
- 版本：1.0.0
- 最低系统：macOS 13.0
- 已启用 App Sandbox
- 已生成 App Icon（桌面有各个尺寸的 png）

---

## 你需要操作的步骤

### Step 1: 注册 Bundle ID
1. 打开 https://developer.apple.com/account/resources/identifiers/list
2. 点击 "+" 注册新 ID
3. 选择 "App IDs" → "App"
4. 输入：
   - Name: `MiniMaxMonitor`
   - Bundle ID: `com.minimax.monitor`
5. 直接 Continue → Register

### Step 2: 创建 App Store 记录
1. 打开 https://appstoreconnect.apple.com
2. 登录后点击 My Apps
3. 点击 "+" → "新建 App"
4. 填写：
   - **平台**：macOS ✓
   - **名称**：MiniMax Monitor
   - **主要语言**：简体中文
   - **套装 ID**：选择 Step 1 注册的 ID
   - **SKU**：`minimax-monitor`（不能重复）
5. 点击创建

### Step 3: 准备截图
需要 3 张截图（用 Cmd+Shift+4 截取）：
- 截图1：菜单栏图标显示
- 截图2：弹出菜单列表
- 截图3：设置页面

### Step 4: 填写 App 信息

**App Information**：
- 类别：工具

**价格与可用性**：
- 价格：免费
- 可用性：所有地区

**元数据**：
- 关键词：minimax, api, monitor, usage, 余额查询, 工具
- 描述：MiniMax Monitor 是 macOS 菜单栏应用，实时显示 MiniMax API 使用量。点击菜单栏图标即可查看各模型剩余额度，支持自动刷新。
- copyright：© 2026 MiniMax Monitor

### Step 5: 用 Xcode 上传
1. 打开项目
2. Xcode → Product → Clean Build Folder
3. Xcode → Product → Build for → Archiving
4. 等待编译完成
5. 点击 "Distribute App"
6. 选择 "App Store Connect"
7. 选择你的开发团队
8. 勾选 "Upload"
9. 点击 Upload

### Step 6: 提交审核
1. 上传成功后，登录 App Store Connect
2. 进入 My Apps → MiniMax Monitor
3. 在 "构建版本" 中选择上传的版本
4. 点击 "提交以供审核"
5. 填写联系方式和备注
6. 点击提交

---

## 常见问题

### Q: 签名证书选什么？
A: 开发时用 "Sign to Run Locally"，上传时用 "Apple Distribution"

### Q: 审核要多久？
A: 通常 1-2 个工作日，周末不算

### Q: 被拒绝怎么办？
A: 查看拒绝原因修复，常见原因：
- 截图不合规（需要真实产品截图）
- 描述问题
- 功能与描述不符