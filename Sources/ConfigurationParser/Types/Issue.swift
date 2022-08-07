import Foundation

public typealias IssueHandler = (Issue) -> Void

public enum Issue: Equatable {
    public struct Context: Equatable {
        public let codingPath: [Name]
        public let description: String
    }

    /// A property that was not defined as part of the configuration options was seen during decoding.
    case unexpectedOption(Name, Context)

    /// A property that is marked as deprecated has been decoded.
    case deprecatedOption(Name, Context)
}

extension Issue: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unexpectedOption(let name, let context):
            return "Found unexpected property \(name.formattedAsQuote(in: context.codingPath)) while decoding."
        case .deprecatedOption(let name, let context):
            return "Property \(name.formattedAsQuote(in: context.codingPath)) is deprecated. \(context.description)"
        }
    }
}

public extension Issue {
    static func log(_ issue: Issue) {
        print(issue.description)
    }
}
