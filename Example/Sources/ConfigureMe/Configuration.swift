import ConfigurationParser
import Foundation

struct Configuration: ParsableConfiguration {
    enum Style: String, Codable {
        case lowercase, uppercase
    }

    @Option
    var style: Style = .lowercase

    @Option
    var repeatCount: Int = 10

    @Option
    var greeting: String = "Hello, how are you?"

    @Option(.deprecated("Renamed to ‘style‘"))
    var isUppercase: Bool? = nil
}
