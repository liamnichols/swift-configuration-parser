import Foundation

/// Describes an individual override of an option
public struct OptionOverride: Equatable {
    /// The property/option name being overridden.
    public var name: Name

    /// The path to the property/option if nested.
    public var path: [Name]

    /// The unparsed data representation of the value to be passed into the decoder when reading.
    public var value: Data

    public init(name: Name, path: [Name] = [], value: Data) {
        self.name = name
        self.path = path
        self.value = value
    }

    /// Returns `nil` if `pathComponents` is empty.
    public init?(pathComponents: [Name], value: Data) {
        var path = pathComponents
        if let name = path.popLast() {
            self.init(name: name, path: path, value: value)
        } else {
            return nil
        }
    }

    /// Attempts to parse a raw string into an `OptionOverride` by splitting name/path and value on the first seen `delimiter`.
    ///
    /// ```swift
    /// if let parsed = OptionOverride("nested.option=true", delimiter: "=") {
    ///     parsed.name  // "option"
    ///     parsed.path  // ["nested"]
    ///     parsed.value // Data("true".utf8)
    /// }
    /// ```
    public init?(_ string: String, delimiter: Character = "=") {
        // Ensure that we can split the path and the value by the assignment operator
        guard let split = string.firstIndex(of: delimiter) else {
            return nil
        }

        // Split the value into the raw key and value
        let key = string[..<split].trimmingCharacters(in: .whitespaces)
        let value = string[split...].dropFirst().trimmingCharacters(in: .whitespaces)

        // Key must be specified and it must to start/finish with a period
        if key.isEmpty || key.hasPrefix(".") || key.hasSuffix(".") {
            return nil
        }

        let components = key.components(separatedBy: ".").map(Name.init(rawValue:))
        self.init(pathComponents: components, value: Data(value.utf8))
    }
}
