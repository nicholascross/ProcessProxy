import Foundation

import ProcessProxyKit
import Vapor
import NIOFoundationCompat

extension Application {
    func setupRoutes(config: ProxyConfig) throws {
        for route in config.routes {
            post(.constant(route.path)) { req -> Response in
                let requestBody = req.body.string ?? ""
                let arguments = try route.extractArguments(requestBody)
                let inputContent = try route.extractInput(requestBody)
                return try await Self.executeProcess(command: route.command, arguments: arguments, inputContent: inputContent)
            }
        }
    }

    private static func executeProcess(command: String, arguments: [String], inputContent: String?) async throws -> Response {
        let outputPipe = Pipe()

        try executeProcessCommand(command: command, arguments: arguments, outputPipe: outputPipe, inputContent: inputContent)

        let body = Response.Body(stream: { writer in
            Task {
                do {
                    try await writeOutputToResponse(outputPipe: outputPipe, writer: writer)
                } catch {
                    print("Failed to write output to response: \(error)")
                }
            }
        })

        return Response(status: .ok, body: body)
    }

    private static func executeProcessCommand(command: String, arguments: [String], outputPipe: Pipe, inputContent: String?) throws {
        let inputPipe = Pipe()
        let process = try Process.executeProcess(command: command, arguments: arguments, inputPipe: inputPipe, outputPipe: outputPipe)

        if let inputContent = inputContent {
            Process.writeInput(pipe: inputPipe, content: inputContent)
        }

        process.waitUntilExit()
    }

    private static func writeOutputToResponse(outputPipe: Pipe, writer: BodyStreamWriter) async throws {
        for try await line in outputPipe.fileHandleForReading.bytes.lines {
            print(line, terminator: "")
            try await writer.write(.buffer(.init(string: "\(line)\n"))).get()
        }
        try await writer.write(.end).get()
        outputPipe.fileHandleForReading.closeFile()
    }
}
