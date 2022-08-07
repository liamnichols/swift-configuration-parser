import ArgumentParser
import ConfigurationParser

extension OptionOverride: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(rawValue: argument)
    }
}
