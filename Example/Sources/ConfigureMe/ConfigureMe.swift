import ArgumentParser
import struct ConfigurationParser.OptionOverride
import Foundation

@main
struct ConfigureMe: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "configure-me",
        abstract: "A tool just begging to be configured",
        version: "0.0.1"
    )

    @Option(
        help: "Path to the configuration file",
        completion: .file(extensions: ["json"])
    )
    var config: String

    @Option(help: "Configuration overrides")
    var configOption: [OptionOverride] = []

    func run() throws {
        let fileURL = URL(fileURLWithPath: config)
        let configuration = try Configuration.parse(contentsOf: fileURL, overrides: configOption) { issue in
            print("NOTE:", issue.description)
        }

        let message: String
        switch configuration.style {
        case .lowercase:
            message = configuration.greeting.lowercased()
        case .uppercase:
            message = configuration.greeting.uppercased()
        }

        for _ in 1...configuration.repeatCount {
            print(message)
        }
    }
}
