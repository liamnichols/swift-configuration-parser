import Foundation

#if canImport(Combine)
// When Combine can be imported, use it's `TopLevelDecoder`.
// This is because other libraries (i.e Yams) already provide conformance
@_exported import protocol Combine.TopLevelDecoder

/// A type that defines methods for decoding.
public typealias TopLevelDecoder = Combine.TopLevelDecoder
#else
// When Combine is not present, redeclare the protocol ourselves

/// A type that defines methods for decoding.
public protocol TopLevelDecoder {

    /// The type this decoder accepts.
    associatedtype Input

    /// Decodes an instance of the indicated type.
    func decode<T>(_ type: T.Type, from: Self.Input) throws -> T where T : Decodable
}

// Add automatic conformance for JSONDecoder
extension JSONDecoder: TopLevelDecoder {
}
#endif
