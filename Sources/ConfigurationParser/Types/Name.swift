import Foundation

public struct Name: RawRepresentable, Hashable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    init(_ codingKey: CodingKey) {
        self.rawValue = codingKey.stringValue
    }
}

// MARK: - Utlis
extension Name {
    /// Formats the name as if it was being quoted in a diagnostic message.
    ///
    /// ```swift
    /// let option: Name = "foo"
    /// option.formattedAsQuote(in: ["bar", "baz"]) // "‘foo‘ (in ‘bar.baz‘)"
    /// option.formattedAsQuote(in: []]) // "‘foo‘"
    /// ```
    public func formattedAsQuote(in path: [Name]) -> String {
        if path.isEmpty {
            return "‘\(rawValue)‘"
        } else {
            let path = path.map(\.rawValue).joined(separator: ".")
            return "‘\(rawValue)‘ (in ‘\(path)‘)"
        }
    }
}

// MARK: - ExpressibleByStringLiteral
extension Name: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)
    }
}
