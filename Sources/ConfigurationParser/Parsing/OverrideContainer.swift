import Foundation

struct OverrideContainer {
    let overrides: [OptionOverride]
    let decoder: DataDecoder

    func decodeIfPresent<T: Decodable>(_ type: T.Type, forKey key: CodingKey, in codingPath: [CodingKey]) throws -> T? {
        let name = Name(key)
        let path = codingPath.map(Name.init(_:))
        guard let override = overrides.first(where: { $0.name == name && $0.path == path }) else { return nil }

        // Decode the value
        do {
            return try decoder.decode(type, from: override.value)
        } catch {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: codingPath + [key],
                debugDescription: "Unable to decode override.",
                underlyingError: error
            ))
        }
    }

    func allKeys(in codingPath: [CodingKey]) -> Set<Name> {
        Set(overrides.filter({ $0.path == codingPath.map(Name.init(_:)) }).map(\.name))
    }
}
