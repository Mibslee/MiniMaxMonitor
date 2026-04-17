import SwiftUI

struct ContentView: View {
    @AppStorage("apiKey") var apiKey: String = ""
    @AppStorage("refreshInterval") var refreshInterval: Int = 60
    @ObservedObject var usageManager = UsageManager.shared
    
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 12) {
            headerView
            
            if apiKey.isEmpty {
                emptyStateView
            } else if usageManager.isLoading {
                loadingView
            } else if let error = usageManager.errorMessage {
                errorView(message: error)
            } else if usageManager.hasUsage {
                usageListView
            } else {
                Text("暂无数据")
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            bottomBar
        }
        .padding()
        .frame(width: 300, height: 360)
        .sheet(isPresented: $showingSettings) {
            SettingsView(isPresented: $showingSettings)
        }
    }
    
    var headerView: some View {
        HStack {
            Text("MiniMax")
                .font(.headline)
            Spacer()
            Button(action: { showingSettings = true }) {
                Image(systemName: "gear")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
        }
    }
    
    var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "key.fill")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("请先设置 API Key")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button("设置 API Key") {
                showingSettings = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 30))
                .foregroundColor(.orange)
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("重试") {
                Task {
                    await usageManager.fetchUsage()
                }
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var usageListView: some View {
        let sortedModels = usageManager.sortedModels
        
        return ScrollView {
            VStack(spacing: 10) {
                ForEach(sortedModels, id: \.modelName) { model in
                    if model.currentIntervalTotalCount > 0 {
                        ModelUsageRow(model: model)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    var bottomBar: some View {
        HStack {
            Button(action: {
                Task {
                    await usageManager.fetchUsage()
                }
            }) {
                Label("刷新", systemImage: "arrow.clockwise")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
            .disabled(usageManager.isLoading)
            
            Spacer()
            
            if let lastUpdated = usageManager.lastUpdated {
                Text(lastUpdated, formatter: timeFormatter)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Label("退出", systemImage: "power")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
        }
    }
    
    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

struct ModelUsageRow: View {
    let model: ModelRemain
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(modelDisplayName)
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
                Text(percentageText)
                    .font(.caption2)
                    .foregroundColor(usageColor)
            }
            
            UsageProgressBar(percentage: usedPercentage)
                .frame(height: 8)
        }
        .padding(8)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(6)
    }
    
    var modelDisplayName: String {
        model.modelName ?? "未知模型"
    }
    
    var usedPercentage: Double {
        guard model.currentIntervalTotalCount > 0 else { return 0 }
        return Double(model.currentIntervalUsageCount) / Double(model.currentIntervalTotalCount) * 100
    }
    
    var percentageText: String {
        let used = model.currentIntervalUsageCount
        let total = model.currentIntervalTotalCount
        return "\(used)/\(total) (\(Int(usedPercentage))%)"
    }
    
    var usageColor: Color {
        return .primary
    }
}

struct UsageProgressBar: View {
    let percentage: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(backgroundColor)
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(barColor)
                    .frame(width: geometry.size.width * CGFloat(percentage / 100), height: 8)
            }
        }
    }
    
    var backgroundColor: Color {
        return Color.green.opacity(0.15)
    }
    
    var barColor: Color {
        return Color(red: 0.2, green: 0.7, blue: 0.3)
    }
}

struct SettingsView: View {
    @Binding var isPresented: Bool
    @AppStorage("apiKey") var apiKey: String = ""
    @AppStorage("refreshInterval") var refreshInterval: Int = 60
    
    @State private var inputKey: String = ""
    @State private var selectedInterval: Int = 60
    @State private var selectedRegion: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("设置")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("区域")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Picker("", selection: $selectedRegion) {
                    ForEach(MiniMaxRegion.allCases, id: \.rawValue) { region in
                        Text(region.rawValue).tag(region.rawValue)
                    }
                }
                .pickerStyle(.radioGroup)
                Text("国际版使用 minimax.io，大陆版使用 minimaxi.com")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("API Key")
                    .font(.subheadline)
                    .fontWeight(.medium)
                SecureField("输入你的 MiniMax API Key", text: $inputKey)
                    .textFieldStyle(.roundedBorder)
                Text("在 MiniMax 开放平台的 \"接口密钥\" 中获取")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("刷新间隔")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Picker("", selection: $selectedInterval) {
                    Text("30秒").tag(30)
                    Text("1分钟").tag(60)
                    Text("5分钟").tag(300)
                    Text("15分钟").tag(900)
                }
                .pickerStyle(.segmented)
            }
            
            Spacer()
            
            HStack {
                Button("取消") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("保存") {
                    apiKey = inputKey
                    refreshInterval = selectedInterval
                    if let region = MiniMaxRegion(rawValue: selectedRegion) {
                        UsageManager.shared.selectedRegion = region
                    }
                    Task {
                        await UsageManager.shared.fetchUsage()
                    }
                    isPresented = false
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 350, height: 380)
        .onAppear {
            inputKey = apiKey
            selectedInterval = refreshInterval
            selectedRegion = UsageManager.shared.selectedRegion.rawValue
        }
    }
}

#Preview {
    ContentView()
}