import Foundation

public struct OptionOverride: RawRepresentable {
    let name: OptionName
    let path: [OptionName]
    let valueString: String

    public init?(rawValue: String) {
        // Ensure that the 'key:value' format was used
        guard let split = rawValue.firstIndex(of: ":") else {
            return nil
        }

        // Split the value into the raw key and value
        let keyString = rawValue[..<split].trimmingCharacters(in: .whitespaces)
        let valueString = rawValue[split...].dropFirst().trimmingCharacters(in: .whitespaces)

        // Key must be specified and it must to start/finish with a period
        if keyString.isEmpty || keyString.hasPrefix(".") || keyString.hasSuffix(".") {
            return nil
        }

        // Work out the coding path for the key (if any)
        let components = keyString.components(separatedBy: ".")
        let name = components.last!
        let path = components.dropLast().map(OptionName.init(rawValue:))

        self.name = OptionName(rawValue: name)
        self.path = path
        self.valueString = valueString
    }

    public var rawValue: String {
        let keyString = (path + [name]).map(\.rawValue).joined(separator: ".")
        return keyString + ":" + valueString
    }
}

extension OptionOverride: ExpressibleByStringLiteral {
    public init(stringLiteral value: StaticString) {
        self.init(rawValue: String(describing: value))!
    }
}
