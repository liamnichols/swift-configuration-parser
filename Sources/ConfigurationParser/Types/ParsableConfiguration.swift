import Foundation

/// A type that can be parsed as part of a configuration file
public protocol ParsableConfiguration: Decodable {
    /// Creates an instance using the definitions given by each property's wrapper.
    ///
    /// - Note: You should not use this initializer to create a default representation of the type. Use the ``default`` static property instead.
    init()
}

public extension ParsableConfiguration {
    /// Returns an instance of the type populated with the defined default values.
    static var `default`: Self {
        try! Self(from: ConfigurationDecoder(
            definitions: options,
            dataContainer: nil,
            overridesContainer: nil,
            codingPath: [],
            issueHandler: { _ in }
        ))
    }

    /// Parses the configuration using the provided data with the given overrides.
    ///
    /// Each option within a configuration is resolved in the following order:
    ///
    /// 1. Overrides defined in the `overrides` array.
    /// 2. The value decoded from the given `data` if it was present.
    /// 3. The default value defined on the type.
    ///
    /// When processing values from `overrides` or `data`, they are decoded using the given `decoder`.
    ///
    /// - Parameters:
    ///   - data: The data representation of the configuration file to be decoded and read from.
    ///   - overrides: An array of individual overrides that take priority over the values defined in the configuration.
    ///   - decoder: A type used to decode the `data` or the `valueString`'s provided in the `overrides`.
    ///   - issueHandler: A closure invoked whenever an issue is detected. By default a message will be printed to the console.
    /// - Returns: The configuration will all options successfully resolved to a value.
    static func parse<T: TopLevelDecoder>(
        _ data: Data,
        overrides: [OptionOverride] = [],
        decoder: T,
        issueHandler: @escaping IssueHandler = Issue.log(_:)
    ) throws -> Self where T.Input == Data {
        try parse(data: data, overrides: overrides, decoder: decoder, issueHandler: issueHandler)
    }

    /// Parses the configuration using the provided data with the given overrides as JSON.
    ///
    /// Each option within a configuration is resolved in the following order:
    ///
    /// 1. Overrides defined in the `overrides` array.
    /// 2. The value decoded from the given `data` if it was present.
    /// 3. The default value defined on the type.
    ///
    /// When processing values from `overrides` or `data`, they are decoded using `JSONDecoder` with a default configuration.
    /// To customise this behaviour, or use a different file format instead, pass a custom decoder using ``parse(_:overrides:decoder:issueHandler:)``.
    ///
    /// - Parameters:
    ///   - data: The data representation of the configuration file to be decoded and read from.
    ///   - overrides: An array of individual overrides that take priority over the values defined in the configuration.
    ///   - issueHandler: A closure invoked whenever an issue is detected. By default a message will be printed to the console.
    /// - Returns: The configuration will all options successfully resolved to a value.
    static func parse(
        _ data: Data,
        overrides: [OptionOverride] = [],
        issueHandler: @escaping IssueHandler = Issue.log(_:)
    ) throws -> Self {
        try parse(data, overrides: overrides, decoder: JSONDecoder(), issueHandler: issueHandler)
    }

    /// Parses the configuration from the given file with the given overrides.
    ///
    /// Each option within a configuration is resolved in the following order:
    ///
    /// 1. Overrides defined in the `overrides` array.
    /// 2. The value decoded from the given `fileURL` if it was present.
    /// 3. The default value defined on the type.
    ///
    /// When processing values from `overrides` or `fileURL`, they are decoded using the given `decoder`.
    ///
    /// - Parameters:
    ///   - data: The data representation of the configuration file to be decoded and read from.
    ///   - overrides: An array of individual overrides that take priority over the values defined in the configuration.
    ///   - decoder: A type used to decode the `data` or the `valueString`'s provided in the `overrides`.
    ///   - issueHandler: A closure invoked whenever an issue is detected. By default a message will be printed to the console.
    /// - Returns: The configuration will all options successfully resolved to a value.
    static func parse<T: TopLevelDecoder>(
        contentsOf fileURL: URL,
        overrides: [OptionOverride] = [],
        decoder: T,
        issueHandler: @escaping IssueHandler = Issue.log(_:)
    ) throws -> Self where T.Input == Data {
        let data = try Data(contentsOf: fileURL)
        return try parse(data, overrides: overrides, decoder: decoder, issueHandler: issueHandler)
    }

    /// Parses the configuration from the given file with the given overrides as JSON.
    ///
    /// Each option within a configuration is resolved in the following order:
    ///
    /// 1. Overrides defined in the `overrides` array.
    /// 2. The value decoded from the given `fileURL` if it was present.
    /// 3. The default value defined on the type.
    ///
    /// When processing values from `overrides` or `fileURL`, they are decoded using `JSONDecoder` with a default configuration.
    /// To customise this behaviour, or use a different file format instead, pass a custom decoder using ``parse(contentsOf:overrides:decoder:issueHandler:)``.
    ///
    /// - Parameters:
    ///   - data: The data representation of the configuration file to be decoded and read from.
    ///   - overrides: An array of individual overrides that take priority over the values defined in the configuration.
    ///   - issueHandler: A closure invoked whenever an issue is detected. By default a message will be printed to the console.
    /// - Returns: The configuration will all options successfully resolved to a value.
    static func parse(
        contentsOf fileURL: URL,
        overrides: [OptionOverride] = [],
        issueHandler: @escaping IssueHandler = Issue.log(_:)
    ) throws -> Self {
        try parse(contentsOf: fileURL, overrides: overrides, decoder: JSONDecoder(), issueHandler: issueHandler)
    }

    /// Parses the configuration using the provided overrides.
    ///
    /// If an override was not specified for a value, it's default will be used instead.
    /// When processing values from `overrides`, they are decoded using the given `decoder`.
    ///
    /// - Parameters:
    ///   - overrides: An array of individual overrides that take priority over the values defined in the configuration.
    ///   - decoder: A type used to decode the `data` or the `valueString`'s provided in the `overrides`.
    ///   - issueHandler: A closure invoked whenever an issue is detected. By default a message will be printed to the console.
    /// - Returns: The configuration will all options successfully resolved to a value.
    static func parse<T: TopLevelDecoder>(
        overrides: [OptionOverride] = [],
        decoder: T,
        issueHandler: @escaping IssueHandler = Issue.log(_:)
    ) throws -> Self where T.Input == Data {
        try parse(data: nil, overrides: overrides, decoder: decoder, issueHandler: issueHandler)
    }

    /// Parses the configuration using the provided overrides as JSON.
    ///
    /// If an override was not specified for a value, it's default will be used instead.
    /// When processing values from `overrides`, they are decoded using `JSONDecoder` with a default configuration.
    /// To customise this behaviour, or use a different file format instead, pass a custom decoder using ``parse(overrides:decoder:issueHandler:)``.
    ///
    /// - Parameters:
    ///   - overrides: An array of individual overrides that take priority over the values defined in the configuration.
    ///   - decoder: A type used to decode the `data` or the `valueString`'s provided in the `overrides`.
    ///   - issueHandler: A closure invoked whenever an issue is detected. By default a message will be printed to the console.
    /// - Returns: The configuration will all options successfully resolved to a value.
    static func parse(
        overrides: [OptionOverride] = [],
        issueHandler: @escaping IssueHandler = Issue.log(_:)
    ) throws -> Self {
        try parse(data: nil, overrides: overrides, decoder: JSONDecoder(), issueHandler: issueHandler)
    }

    /// Internal implementation
    private static func parse<T: TopLevelDecoder>(
        data: Data?,
        overrides: [OptionOverride],
        decoder: T,
        issueHandler: @escaping IssueHandler
    ) throws -> Self where T.Input == Data {
        try Self(from: ConfigurationDecoder(
            definitions: options,
            dataContainer: data.flatMap { try decoder.decode(DecodableContainer.self, from: $0) },
            overridesContainer: OverrideContainer(overrides: overrides, decoder: TopLevelDataDecoder(decoder)),
            codingPath: [],
            issueHandler: issueHandler
        ))
    }
}

public extension ParsableConfiguration {
    /// Returns an array of option definitions resolved by reflecting the type using `Mirror`.
    ///
    /// ``ParsableConfiguration`` uses this information when when parsing the type, but you can also use it downstream in your own tooling for things like documentation generation.
    static var options: [OptionDefinition] {
        Mirror(reflecting: Self())
            .children
            .compactMap(definition(from:))
    }

    private static func definition(from child: Mirror.Child) -> OptionDefinition? {
        guard let codingKey = child.label else { return nil }

        // Property wrappers have underscore-prefixed names, be sure to strip
        let name: Name
        if codingKey.hasPrefix("_") {
            name = Name(rawValue: String(codingKey.dropFirst()))
        } else {
            name = Name(rawValue: codingKey)
        }

        // If the property was a property wrapper, return it's definition
        if let provider = child.value as? OptionDefinitionProvider {
            return provider.optionDefinition(for: name)
        }

        // Otherwise build a basic one from the property itself
        return OptionDefinition(
            name: name,
            content: .defaultValue(child.value),
            availability: .available,
            documentation: Documentation()
        )
    }
}

