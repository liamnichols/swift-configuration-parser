import Foundation

public typealias IssueHandler = (Issue) -> Void

public enum Issue: Equatable {
    public struct Context: Equatable {
        public let codingPath: [OptionName]
        public let description: String
    }

    /// A property that was not defined as part of the configuration options was seen during decoding.
    case unexpectedOption(OptionName, Context)

    /// A property that is marked as deprecated has been decoded.
    case deprecatedOption(OptionName, Context)
}

extension OptionName {
    func format(in path: [OptionName]) -> String {
        if path.isEmpty {
            return "‘\(rawValue)‘"
        } else {
            let path = path.map(\.rawValue).joined(separator: ".")
            return "‘\(rawValue)‘ (in ‘\(path)‘)"
        }
    }
}

extension Issue: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unexpectedOption(let name, let context):
            return "Found unexpected property \(name.format(in: context.codingPath)) while decoding."
        case .deprecatedOption(let name, let context):
            return "Property \(name.format(in: context.codingPath)) is deprecated. \(context.description)"
        }
    }
}

public extension Issue {
    static func log(_ issue: Issue) {
        print(issue.description)
    }
}
