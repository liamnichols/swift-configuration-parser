import Foundation

struct ConfigurationDecoder {
    let definitions: [OptionName: OptionDefinition]
    let dataContainer: DecodableContainer?
    let overridesContainer: OverrideContainer?
    let codingPath: [CodingKey]
    let issueHandler: IssueHandler
    let userInfo: [CodingUserInfoKey: Any]
    let allKeys: Set<OptionName>

    init(
        definitions: [OptionDefinition],
        dataContainer: DecodableContainer?,
        overridesContainer: OverrideContainer?,
        codingPath: [CodingKey],
        issueHandler: @escaping IssueHandler
    ) {
        let definitions = Dictionary(uniqueKeysWithValues: definitions.map({ ($0.name, $0) }))
        let allKeys = (dataContainer?.allKeys ?? []).union((overridesContainer?.allKeys(in: codingPath) ?? []))

        self.definitions = definitions
        self.dataContainer = dataContainer
        self.overridesContainer = overridesContainer
        self.codingPath = codingPath
        self.issueHandler = issueHandler
        self.userInfo = [:]
        self.allKeys = allKeys

        lazy var codingPath: [OptionName] = codingPath.map(OptionName.init(_:))
        for key in allKeys {
            if let definition = definitions[key], case .deprecated(let message) = definition.availability {
                let context = Issue.Context(codingPath: codingPath, description: message)
                issueHandler(.deprecatedOption(key, context))
            }

            if definitions[key] == nil {
                let context = Issue.Context(codingPath: codingPath, description: "")
                issueHandler(.unexpectedOption(key, context))
            }
        }
    }
}

// MARK: Decoder
extension ConfigurationDecoder: Decoder {
    func container<Key: CodingKey>(
        keyedBy type: Key.Type
    ) throws -> KeyedDecodingContainer<Key> {
        let container = ConfigurationDecodingContainer<Key>(for: self, codingPath: codingPath)
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError()
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        fatalError()
    }

    func value<T: Decodable>(forKey key: StringCodingKey) throws -> T {
        fatalError()
    }
}

final class ConfigurationDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {
    var codingPath: [CodingKey]
    let decoder: ConfigurationDecoder

    init(for decoder: ConfigurationDecoder, codingPath: [CodingKey]) {
        self.codingPath = codingPath
        self.decoder = decoder
    }

    var allKeys: [K] {
        decoder.allKeys.compactMap { K(stringValue: $0.rawValue) }
    }

    func contains(_ key: K) -> Bool {
        decoder.allKeys.contains(OptionName(key))
    }

    func decodeNil(forKey key: K) throws -> Bool {
        true // TODO: Figure this out
    }

    func decode<T: Decodable>(_ type: T.Type, forKey key: K) throws -> T {
        guard let definition = decoder.definitions[OptionName(key)] else {
            throw DecodingError.keyNotFound(key, .init(codingPath: codingPath, debugDescription: """
                Trying to decode a key that is not known. Did you annotate it with @Option?
                """))
        }

        let decoder = OptionDecoder(
            underlying: decoder,
            codingPath: codingPath + [key],
            definition: definition
        )

        return try T(from: decoder)
    }

    func decodeIfPresent<T: Decodable>(_ type: T.Type, forKey key: K) throws -> T? {
        fatalError()
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }

    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        fatalError()
    }

    func superDecoder() throws -> Decoder {
        fatalError()
    }

    func superDecoder(forKey key: K) throws -> Decoder {
        fatalError()
    }
}

struct OptionDecoder: Decoder {
    var underlying: ConfigurationDecoder
    var codingPath: [CodingKey]
    var definition: OptionDefinition

    var userInfo: [CodingUserInfoKey : Any] { underlying.userInfo }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = ConfigurationDecodingContainer<Key>(for: underlying, codingPath: codingPath)
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError()
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        OptionContainer(decoder: self, codingPath: codingPath)
    }

    func decodeIfPresent<T: Decodable>(_ type: T.Type) throws -> T? {
        let key = StringCodingKey(codingPath.last!)

        if let value = try underlying.overridesContainer?.decodeIfPresent(type, forKey: key, in: codingPath.dropLast()) {
            return value
        }

        return  try underlying.dataContainer?.decodeIfPresent(type, forKey: key)
    }
}

struct OptionContainer: SingleValueDecodingContainer {
    var decoder: OptionDecoder
    var codingPath: [CodingKey]

    func decodeNil() -> Bool {
        fatalError()
    }

    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        switch decoder.definition.content {
        case let .defaultValue(defaultValue):
            return try decodeOption(as: type, defaultValue: defaultValue as! T)
        case .container(let definitions):
            return try decodeContainer(as: type, definitions: definitions)
        }
    }

    private func decodeOption<T: Decodable>(as type: T.Type, defaultValue: T) throws -> T {
        // Try and decode the value if it was known to the decoder
        if let value = try decoder.decodeIfPresent(T.self) {
            return value
        }

        // Otherwise use the default value
        return defaultValue
    }

    private func decodeContainer<T: Decodable>(as type: T.Type, definitions: [OptionDefinition]) throws -> T {
        // Decode from the dataContainer if present
        let nestedContainer = try decoder.decodeIfPresent(DecodableContainer.self)
        return try T(from: ConfigurationDecoder(
            definitions: definitions,
            dataContainer: nestedContainer,
            overridesContainer: decoder.underlying.overridesContainer,
            codingPath: codingPath,
            issueHandler: decoder.underlying.issueHandler
        ))
    }
}
