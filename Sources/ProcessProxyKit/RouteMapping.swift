import Foundation

public enum CommandArgumentType: String, Decodable, Sendable {
    case argumentConstant = "constant"
    case argumentMapping = "argument"
    case optionMapping = "option"
}

public enum CommandArgument: Decodable, Sendable {
    enum CodingKeys: CodingKey {
        case type
        case value
        case option
    }

    case argumentConstant(String)
    case argumentMapping(String)
    case optionMapping(String, String)

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(CommandArgumentType.self, forKey: .type)
        switch type {
        case .argumentConstant:
            let value = try container.decode(String.self, forKey: .value)
            self = .argumentConstant(value)
        case .argumentMapping:
            let value = try container.decode(String.self, forKey: .value)
            self = .argumentMapping(value)
        case .optionMapping:
            let option = try container.decode(String.self, forKey: .option)
            let value = try container.decode(String.self, forKey: .value)
            self = .optionMapping(option, value)
        }
    }

}

public struct RouteMapping: Decodable, Sendable {
    /// path to match in the request
    public let path: String

    /// command to execute
    public let command: String

    public let arguments: [CommandArgument]?

    /// dynamic input mapped from request body piped to command
    public let inputMapping: String?

    public func extractArguments(_ requestBody: String) throws -> [String] {
        var extractedArguments: [String] = []
        for argument in arguments ?? [] {
            switch argument {
            case .argumentConstant(let value):
                extractedArguments.append(value)
            case .argumentMapping(let filter):
                let value = try Process.jq(filter: filter, input: requestBody)
                extractedArguments.append(value)
            case .optionMapping(let option, let filter):
                let value = try Process.jq(filter: filter, input: requestBody)
                if !value.isEmpty {
                    extractedArguments.append(option)
                    extractedArguments.append(value)
                }
            }
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
