import Foundation

protocol OptionDefinitionProvider {
    func optionDefinition(for name: Name) -> OptionDefinition
}
