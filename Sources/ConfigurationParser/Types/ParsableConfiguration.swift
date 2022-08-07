import Foundation

public protocol ParsableConfiguration: Decodable {
    init()
}

public extension ParsableConfiguration {
    static var `default`: Self {
        try! Self(from: ConfigurationDecoder(
            definitions: options,
            dataContainer: nil,
            overridesContainer: nil,
            codingPath: [],
            issueHandler: { _ in }
        ))
    }

    static func parse(
        using data: Data,
        overrides: [OptionOverride] = [],
        decoder: DecoderProtocol = JSONDecoder(),
        issueHandler: @escaping IssueHandler = Issue.log(_:)
    ) throws -> Self {
        try Self(from: ConfigurationDecoder(
            definitions: options,
            dataContainer: try decoder.decode(DecodableContainer.self, from: data),
            overridesContainer: OverrideContainer(overrides: overrides, decoder: decoder),
            codingPath: [],
            issueHandler: issueHandler
        ))
    }
}

public extension ParsableConfiguration {
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

