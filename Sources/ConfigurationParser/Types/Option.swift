import Foundation

enum Parsed<Value> {
    case value(Value)
    case definition((Name) -> OptionDefinition)

    init(_ makeDefinition: @escaping (Name) -> OptionDefinition) {
        self = .definition(makeDefinition)
    }
}

@propertyWrapper public struct Option<Wrapped> {
    var _parsedOption: Parsed<Wrapped>

    init(_parsedOption: Parsed<Wrapped>) {
        self._parsedOption = _parsedOption
    }

    /// This initializer works around a quirk of property wrappers, where the
    /// compiler will not see no-argument initializers in extensions. Explicitly
    /// marking this initializer unavailable means that when `Value` conforms to
    /// `ExpressibleByArgument`, that overload will be selected instead.
    ///
    /// ```swift
    /// @Argument() var foo: String // Syntax without this initializer
    /// @Argument var foo: String   // Syntax with this initializer
    /// ```
    @available(*, unavailable, message: "A default value must be provided unless the value type conforms to ExpressibleByArgument.")
    public init() {
        fatalError("unavailable")
    }

    public var wrappedValue: Wrapped {
        get {
            switch _parsedOption {
            case .value(let wrapped):
                return wrapped
            case .definition:
                fatalError() // TODO: Better error
            }
        }
        set {
            _parsedOption = .value(newValue)
        }
    }
}

public extension Option {
    init(
        wrappedValue: Wrapped,
        _ availability: Availability = .available,
        summary: String = "",
        discussion: String = "",
        hidden: Bool = false
    ) {
        self.init(_parsedOption: .init { name in
            OptionDefinition(
                name: name,
                content: .defaultValue(wrappedValue),
                availability: availability,
                documentation: Documentation(summary: summary, discussion: discussion, hidden: hidden)
            )
        })
    }
}

public extension Option where Wrapped: ParsableConfiguration {
    init(
        _ availability: Availability = .available,
        summary: String = "",
        discussion: String = "",
        hidden: Bool = false
    ) {
        self.init(_parsedOption: .init { name in
            OptionDefinition(
                name: name,
                content: .container(Wrapped.options),
                availability: availability,
                documentation: Documentation(summary: summary, discussion: discussion, hidden: hidden)
            )
        })
    }
}

// MARK: - Decoding

extension Option: OptionDefinitionProvider {
    func optionDefinition(for name: Name) -> OptionDefinition {
        switch _parsedOption {
        case .value:
            fatalError("Trying to get option definition from a resolved property")
        case .definition(let provide):
            return provide(name)
        }
    }
}

extension Option: Decodable where Wrapped: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let wrapped = try container.decode(Wrapped.self)
        self.init(_parsedOption: .value(wrapped))
    }
}
