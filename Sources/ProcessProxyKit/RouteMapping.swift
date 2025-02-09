import Foundation

public struct RouteMapping: Codable, Sendable {
    /// path to match in the request
    public let path: String

    /// command to execute
    public let command: String

    /// dynamic arguments mapped from request body
    public let argumentMappings: [String]?

    /// dynamic options mapped from request body
    public let optionMappings: [String: String]?

    /// hardcoded arguments, options or flags
    public let arguments: [String]?

    /// dynamic input mapped from request body piped to command
    public let inputMapping: String?

    public func extractArguments(_ requestBody: String) throws -> [String] {
        var extractedArguments: [String] = []

        for argument in argumentMappings ?? [] {
            let value = try Process.jq(filter: argument, input: requestBody)
            extractedArguments.append(value)
        }

        for (option, filter) in optionMappings ?? [:] {
            let value = try Process.jq(filter: filter, input: requestBody)
                if !value.isEmpty {
                    extractedArguments.append(option)
                    extractedArguments.append(value)
                }
        }

        for argument in arguments ?? [] {
            extractedArguments.append(argument)
        }

        return extractedArguments
    }

    public func extractInput(_ requestBody: String) throws -> String? {
        if let inputMapping = inputMapping {
            return try Process.jq(filter: inputMapping, input: requestBody)
        } else {
            return nil
        }
    }
}
