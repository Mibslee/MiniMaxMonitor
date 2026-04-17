import Foundation

enum MiniMaxRegion: String, CaseIterable {
    case global = "Global (minimax.io)"
    case cn = "中国大陆 (minimaxi.com)"

    var baseURL: String {
        switch self {
        case .global: return "https://www.minimax.io"
        case .cn: return "https://www.minimaxi.com"
        }
    }
}

struct UsageResponse: Codable {
    let modelRemains: [ModelRemain]?
    let baseResp: BaseResp?

    enum CodingKeys: String, CodingKey {
        case modelRemains = "model_remains"
        case baseResp = "base_resp"
    }
}

struct ModelRemain: Codable {
    let modelName: String?
    let currentIntervalTotalCount: Int
    let currentIntervalUsageCount: Int
    let startTime: Int64
    let endTime: Int64

    enum CodingKeys: String, CodingKey {
        case modelName = "model_name"
        case currentIntervalTotalCount = "current_interval_total_count"
        case currentIntervalUsageCount = "current_interval_usage_count"
        case startTime = "start_time"
        case endTime = "end_time"
    }

    // API returns remaining quota in currentIntervalUsageCount (confusing name, confirmed by observed data)
    var remaining: Int {
        currentIntervalUsageCount
    }

    var remainingPercentage: Double {
        guard currentIntervalTotalCount > 0 else { return 0 }
        return Double(currentIntervalUsageCount) / Double(currentIntervalTotalCount) * 100
    }

    var resetDate: Date {
        Date(timeIntervalSince1970: Double(endTime) / 1000)
    }
}

struct BaseResp: Codable {
    let statusCode: Int
    let statusMsg: String

    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case statusMsg = "status_msg"
    }
}

@MainActor
class UsageManager: ObservableObject {
    static let shared = UsageManager()

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var modelRemains: [ModelRemain] = []
    @Published var lastUpdated: Date?

    var selectedRegion: MiniMaxRegion {
        get {
            let rawValue = UserDefaults.standard.string(forKey: "selectedRegion") ?? MiniMaxRegion.cn.rawValue
            return MiniMaxRegion(rawValue: rawValue) ?? .cn
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "selectedRegion")
        }
    }

    var baseURL: String {
        selectedRegion.baseURL
    }

    func fetchUsage() async {
        let apiKey = UserDefaults.standard.string(forKey: "apiKey") ?? ""

        guard !apiKey.isEmpty else {
            errorMessage = "请先设置 API Key"
            return
        }

        isLoading = true
        errorMessage = nil
        // Fix #7: defer ensures isLoading is always reset, no matter which path exits
        defer { isLoading = false }

        let urlString = "\(baseURL)/v1/api/openplatform/coding_plan/remains"

        // Fix #3: guard against invalid URL instead of force-unwrapping
        guard let url = URL(string: urlString) else {
            errorMessage = "无效的请求地址"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "无效的响应"
                return
            }

            if httpResponse.statusCode != 200 {
                if httpResponse.statusCode == 401 {
                    errorMessage = "API Key 无效，请重新设置"
                } else if httpResponse.statusCode == 403 {
                    errorMessage = "无权限，请检查 API Key"
                } else if httpResponse.statusCode >= 500 {
                    errorMessage = "服务器错误，请稍后重试"
                } else {
                    errorMessage = "请求失败: \(httpResponse.statusCode)"
                }
                return
            }

            let decoded = try JSONDecoder().decode(UsageResponse.self, from: data)

            if decoded.baseResp?.statusCode == 0, let remains = decoded.modelRemains {
                self.modelRemains = remains.sorted { $0.currentIntervalTotalCount > $1.currentIntervalTotalCount }
                self.lastUpdated = Date()
            } else {
                errorMessage = decoded.baseResp?.statusMsg ?? "解析失败"
            }
        } catch {
            errorMessage = "网络错误: \(error.localizedDescription)"
        }
    }

    // Fix #6: merge duplicate MiniMax-M lookup into one property
    var codingPlanRemain: ModelRemain? {
        modelRemains.first { $0.modelName?.contains("MiniMax-M") == true }
    }

    var textModelPercentage: Double {
        codingPlanRemain?.remainingPercentage ?? 100
    }

    var hasUsage: Bool {
        !modelRemains.isEmpty
    }

    var sortedModels: [ModelRemain] {
        let filtered = modelRemains.filter { $0.currentIntervalTotalCount > 0 }
        let miniMaxM = filtered.filter { $0.modelName?.contains("MiniMax-M") == true }
        let others = filtered
            .filter { $0.modelName?.contains("MiniMax-M") == false }
            .sorted { $0.remainingPercentage < $1.remainingPercentage }  // 余量少（用量多）的排前面
        return miniMaxM + others
    }
}
