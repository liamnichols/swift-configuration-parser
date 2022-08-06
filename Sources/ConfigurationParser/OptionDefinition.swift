import Foundation

public enum OptionAvailability {
    case available
    case deprecated(String = "")

    static var deprecated: OptionAvailability { .deprecated() }
}

struct OptionDefinition {
    enum Content {
        case defaultValue(Any)
        case container([OptionDefinition])
    }

    let name: OptionName
    let content: Content
    let availability: OptionAvailability
    let documentation: Documentation?
}
