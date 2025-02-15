import Foundation

import ProcessProxyKit
import Vapor
import NIOFoundationCompat

extension Application {
    func setupRoutes(config: ProxyConfig) throws {
        for route in config.routes {
            post(route.path.components(separatedBy: "/").map { .constant($0) }) { req -> Response in
                let requestBody = req.body.string ?? ""
                let arguments = try route.extractArguments(requestBody)
                let inputContent = try route.extractInput(requestBody)
                return try await Self.executeProcess(command: route.command, arguments: arguments, inputContent: inputContent, contentType: route.contentType ?? "text/plain")
            }
        }
    }

    private static func executeProcess(command: String, arguments: [String], inputContent: String?, contentType: String) async throws -> Response {
        let outputPipe = Pipe()

        let process = try executeProcessCommand(command: command, arguments: arguments, outputPipe: outputPipe, inputContent: inputContent)

        let body = Response.Body(asyncStream: { writer in
            try await Task {
                try await writeOutputToResponse(outputPipe: outputPipe, writer: writer)
                process.waitUntilExit()
                fflush(stdout)
            }.value
        })

        let headers = HTTPHeaders([("Content-Type", contentType)])

        return Response(status: .ok, headers: headers, body: body)
    }

    private static func executeProcessCommand(command: String, arguments: [String], outputPipe: Pipe, inputContent: String?) throws -> Process {
        let inputPipe = Pipe()
        let process = try Process.executeProcess(command: command, arguments: arguments, inputPipe: inputPipe, outputPipe: outputPipe)

        if let inputContent = inputContent {
            Process.writeInput(pipe: inputPipe, content: inputContent)
        }

        return process
    }

    private static func writeOutputToResponse(outputPipe: Pipe, writer: AsyncBodyStreamWriter) async throws {
        for try await line in outputPipe.fileHandleForReading.bytes.lines {
            try await writer.write(.buffer(.init(string: "\(line)\n")))
        }
        try await writer.write(.end)
        outputPipe.fileHandleForReading.closeFile()
    }
}
