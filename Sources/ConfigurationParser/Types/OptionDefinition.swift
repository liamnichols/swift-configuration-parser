import Foundation

public struct OptionDefinition {
    /// The name of the option that is represented by this definition.
    public let name: Name

    /// The content of the option. Either a default value (erased to `Any`) or an array of child definitions if the option is a container.
    public let content: Content

    /// The availability of the option.
    public let availability: Availability

    /// Documentation describing the option.
    public let documentation: Documentation
}
