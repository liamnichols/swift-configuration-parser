import Foundation

public struct Documentation {
    public var summary: String
    public var hidden: Bool
    public var discussion: String

    public init(hidden: Bool = false, summary: String = "", discussion: String = "") {
        self.hidden = hidden
        self.summary = summary
        self.discussion = discussion
    }
}

extension Documentation: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(summary: value)
    }
}
