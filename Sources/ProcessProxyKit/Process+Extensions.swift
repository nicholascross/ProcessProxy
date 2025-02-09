import Foundation

extension Process {

    @discardableResult
    public static func which(_ command: String) throws -> String {
        let process = Process()
        let outputPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.standardOutput = outputPipe
        process.arguments = [command]

        try process.run()

        process.waitUntilExit()

        return readOutput(pipe: outputPipe).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public static func jq(filter: String, input: String) throws -> String {
        let inputPipe = Pipe()
        let outputPipe = Pipe()
        try executeProcess(command: "jq", arguments: [filter, "-r"], inputPipe: inputPipe, outputPipe: outputPipe)
        writeInput(pipe: inputPipe, content: input)
        return readOutput(pipe: outputPipe)
    }
    
    @discardableResult
    public static func executeProcess(command: String, arguments: [String], inputPipe: Pipe? = nil, outputPipe: Pipe = Pipe()) throws -> Process {
        let process = Process()
        process.executableURL = try URL(fileURLWithPath: which(command))
        process.arguments = sanitizeArguments(arguments)
        process.standardInput = inputPipe
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        try process.run()
        return process
    }

    public static func writeInput(pipe: Pipe, content: String) {
        guard let inputData = content.data(using: .utf8) else {
            return
        }
        pipe.fileHandleForWriting.write(inputData)
        pipe.fileHandleForWriting.closeFile()
    }

    public static func readOutput(pipe: Pipe) -> String {
        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(decoding: outputData, as: UTF8.self)
    }
    
    private static func sanitizeArguments(_ arguments: [String]) -> [String] {
        return arguments.map { $0.contains(" ") ? "\"\($0)\"" : $0 }
    }
}

