import Foundation

public struct Documentation {
    /// A short summary. Typically just a single sentence.
    public var summary: String

    /// Longer discussion.
    public var discussion: String

    /// If the documentation should be hidden or not.
    public var hidden: Bool

    public init(summary: String = "", discussion: String = "", hidden: Bool = true) {
        self.summary = summary
        self.discussion = discussion
        self.hidden = hidden
    }
}
