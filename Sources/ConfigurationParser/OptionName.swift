import Foundation

public struct OptionName: RawRepresentable, Hashable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    init(_ codingKey: CodingKey) {
        self.rawValue = codingKey.stringValue
    }
}
