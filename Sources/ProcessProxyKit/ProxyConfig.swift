import Foundation

public struct ProxyConfig: Codable {
    public let routes: [RouteMapping]

    public static func loadConfig(path: String) throws -> ProxyConfig {
        let configURL = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: configURL)
        return try JSONDecoder().decode(ProxyConfig.self, from: data)
    }
}
