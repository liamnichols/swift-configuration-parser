import Foundation

public enum Content {
    /// A simple option with a default value.
    case defaultValue(Any)

    /// A container with other child options.
    case container([OptionDefinition])
}
