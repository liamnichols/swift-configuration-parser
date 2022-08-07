import Foundation

/// An internal protocol that describes a top-level decoder that specialises decoding `Data` only.
protocol DataDecoder {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

/// A wrapper for helping to erase the `Input` type from the `TopLevelDecoder` into `TopLevelDataDecoder`
struct TopLevelDataDecoder<Decoder: TopLevelDecoder> where Decoder.Input == Data {
    let decoder: Decoder

    init(_ decoder: Decoder) {
        self.decoder = decoder
    }
}

extension TopLevelDataDecoder: DataDecoder {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try decoder.decode(type, from: data)
    }
}

