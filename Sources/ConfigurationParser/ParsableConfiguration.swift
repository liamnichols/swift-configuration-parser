import Foundation

public protocol ParsableConfiguration: Decodable {
    init()
}

public extension ParsableConfiguration {
    static var `default`: Self {
        try! Self(from: ConfigurationDecoder(
            definitions: options,
            dataContainer: nil,
            codingPath: [],
            issueHandler: { _ in }
        ))
    }

    static func parse(
        using data: Data,
        decoder: DecoderProtocol = JSONDecoder(),
        issueHandler: @escaping IssueHandler = Issue.log(_:)
    ) throws -> Self {
        try Self(from: ConfigurationDecoder(
            definitions: options,
            dataContainer: try decoder.decode(DecodableContainer.self, from: data),
            codingPath: [],
            issueHandler: issueHandler
        ))
    }
}

extension ParsableConfiguration {
    static var options: [OptionDefinition] {
        Mirror(reflecting: Self())
            .children
            .compactMap(definition(from:))
    }

    static func definition(from child: Mirror.Child) -> OptionDefinition? {
        guard let codingKey = child.label else { return nil }

        // Property wrappers have underscore-prefixed names, be sure to strip
        let name: OptionName
        if codingKey.hasPrefix("_") {
            name = OptionName(rawValue: String(codingKey.dropFirst()))
        } else {
            name = OptionName(rawValue: codingKey)
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
            documentation: Documentation(hidden: true)
        )
    }
}

