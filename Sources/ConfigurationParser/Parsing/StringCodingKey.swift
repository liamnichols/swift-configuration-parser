import Foundation

struct StringCodingKey: Hashable {
    var stringValue: String
    var intValue: Int?
}

extension StringCodingKey: CodingKey {
    init?(stringValue: String) {
        self.init(stringValue: stringValue, intValue: nil)
    }

    init?(intValue: Int) {
        self.init(stringValue: String(describing: intValue), intValue: intValue)
    }
}

extension StringCodingKey: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self.init(stringValue: value, intValue: nil)
    }
}

extension StringCodingKey {
    init(_ key: CodingKey) {
        self.init(stringValue: key.stringValue, intValue: key.intValue)
    }
}
