import Foundation

/// Helper for dynamically decoding keyed values from a decoded container.
struct DecodableContainer: Decodable {
    let _container: KeyedDecodingContainer<StringCodingKey>

    init(from decoder: Decoder) throws {
        self._container = try decoder.container(keyedBy: StringCodingKey.self)
    }

    var allKeys: [String] {
        _container.allKeys.map(\.stringValue)
    }

    func decode<T: Decodable>(_ type: T.Type, forKey key: StringCodingKey) throws -> T {
        try _container.decode(type, forKey: key)
    }

    func decodeIfPresent<T: Decodable>(_ type: T.Type, forKey key: StringCodingKey) throws -> T? {
        try _container.decodeIfPresent(type, forKey: key)
    }
}
