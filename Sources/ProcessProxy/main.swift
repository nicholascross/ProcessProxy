import ProcessProxyKit
import Vapor

do {
    try Process.which("jq")
} catch {
    print("jq is required to run this application")
    exit(1)
}

var env = try Environment.detect()
let app = Application(env)
defer { app.shutdown() }

do {
    let config = try ProxyConfig.loadConfig(path: "./config.json")
    try app.setupRoutes(config: config)
} catch {
    print("Failed to configure the application: \(error)")
    exit(1)
}

try app.run()
