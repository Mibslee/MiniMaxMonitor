# App Store 上架指南

## 你需要准备的

### 1. Apple 开发者账号
- **必须**：加入 Apple Developer Program
- 地址：https://developer.apple.com/programs/
- 费用：¥688/年
- 用你的 Apple ID 注册并支付年费

### 2. App Store Connect 账号
- 地址：https://appstoreconnect.apple.com
- 用你的 Apple ID 登录

---

## 我已准备好的

### ✅ 项目配置
- Bundle ID: `com.minimax.monitor`
- 版本：1.0.0
- 最低系统：macOS 13.0
- 已启用 App Sandbox（用于审核）
- 已设置 High Resolution 支持

---

## 你需要操作的步骤

### Step 1: 注册 Bundle ID
1. 打开 https://developer.apple.com/account/resources/identifiers/list
2. 点击 "+" 注册新 ID
3. 选择 "App IDs" → "App"
4. 输入：
   - Name: `MiniMaxMonitor`
   - Bundle ID: `com.minimax.monitor`（或你自定义的）
5. 选择功能：不需要额外功能，直接提交
6. 点击 Register

### Step 2: 创建 App Store 记录
1. 打开 https://appstoreconnect.apple.com
2. 登录后点击 "+" → "新建 App"
3. 填写：
   - **平台**：macOS
   - **名称**：MiniMax Monitor
   - **主要语言**：简体中文
   - **套装 ID**：选择 Step 1 注册的 ID
   - **SKU**：可填 `minimax-monitor-1`（不能重复）
4. 点击创建

### Step 3: 准备截图
需要 macOS 应用的截图，可用快捷键截图：
1. 打开应用，运行程序
2. 按 `Cmd + Shift + 4` 截图
3. 截图会保存到桌面

**需要的截图**：
- 菜单栏图标截图（状态栏显示圆环）
- 弹出菜单截图（显示使用量列表）
- 设置页面截图

### Step 4: 填写 App 信息
在 App Store Connect 中填写：

**元数据**：
- 应用名称：MiniMax Monitor
- 关键词：minimax, api, monitor, usage, 余额查询
- 描述：实时监控 MiniMax API 使用量，菜单栏显示快捷方便
-copyright：© 2026 MiniMax Monitor

**价格与可用性**：
- 价格：免费
- 可用性：所有地区

### Step 5: 使用 Xcode 上传
1. 打开项目
2. Xcode → Product → Clean Build Folder
3. Xcode → Product → Build for → Archiving
4. 等待编译完成
5. 点击 "Distribute App"
6. 选择 "App Store Connect"
7. 选择你的开发团队
8. 点击 Upload

### Step 6: 提交审核
1. 上传成功后，在 App Store Connect 会看到构建版本
2. 点击 "提交以供审核"
3. 填写：
   - 账户联系方式：你的邮箱
   - 备注：简单说明应用功能（如：查看 MiniMax API 使用量）
4. 点击提交

---

## 常见问题

### Q: 签名证书选择什么？
A: 开发时用 "-"(Sign to Run Locally)，上传 App Store 时用 "Apple Development" 或 "Apple Distribution"

### Q: 需要测试账号吗？
A: 不需要，macOS 应用不需要测试账号

### Q: 审核要多久？
A: 通常 1-2 个工作日

### Q: 被拒绝怎么办？
A: 查看拒绝原因，修复后重新提交。通常原因是截图不合规或描述问题