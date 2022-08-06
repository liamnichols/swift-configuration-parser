import Foundation

struct OverrideContainer {
    let overrides: [OptionOverride]
    let decoder: DecoderProtocol

    func decodeIfPresent<T: Decodable>(_ type: T.Type, forKey key: CodingKey, in codingPath: [CodingKey]) throws -> T? {
        let name = OptionName(key)
        let path = codingPath.map(OptionName.init(_:))
        guard let override = overrides.first(where: { $0.name == name && $0.path == path }) else { return nil }

        // Decode the value
        let data = Data(override.valueString.utf8)
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: codingPath + [key],
                debugDescription: "Unable to decode override.",
                underlyingError: error
            ))
        }
    }

    func allKeys(in codingPath: [CodingKey]) -> Set<OptionName> {
        Set(overrides.filter({ $0.path == codingPath.map(OptionName.init(_:)) }).map(\.name))
    }
}
