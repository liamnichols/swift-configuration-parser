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
