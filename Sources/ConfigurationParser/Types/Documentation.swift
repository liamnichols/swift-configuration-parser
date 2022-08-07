import Foundation

public struct Documentation {
    public var summary: String
    public var discussion: String
    public var hidden: Bool

    public init(summary: String = "", discussion: String = "", hidden: Bool = true) {
        self.summary = summary
        self.discussion = discussion
        self.hidden = hidden
    }
}
