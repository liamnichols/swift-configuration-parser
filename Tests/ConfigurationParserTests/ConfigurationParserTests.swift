import ConfigurationParser
import XCTest

final class ConfigurationParserTests: XCTestCase {
    struct Configuration: ParsableConfiguration {
        enum Power: Int, Decodable {
            case low, medium, high
        }

        @Option(
            summary: "The power level used if not otherwise specified.",
            discussion: """
                When setting a default power level, it is crucial that you \
                are sure that the consumption will not exceed the daily \
                allocated allowance. Failure to keep within your usage \
                limits will result in termination of the contract.

                It's recommended that you do not change this value unless \
                you are fully aware of the risks involved.
                """
        )
        var defaultPowerLevel: Power = .medium

        @Option(summary: "Array of preferred spoken languages")
        var preferredLanguages: [String] = ["en", "fr", "ar"]

        @Option(
            .deprecated("Replaced by ‘preferredLanguages‘"),
            summary: "The preferred spoken language",
            hidden: true
        )
        var preferredLanguage: String? = nil

        var showInternalMenu: Bool = false

        @Option(summary: "Details of the author used when creating commits")
        var author: Author

        struct Author: ParsableConfiguration {
            @Option(summary: "The full name of the author")
            var name: String = "John Doe"

            @Option(summary: "The email address of the author")
            var email: String = "no-reply@example.com"
        }
    }


    func testDefaultConfiguration() {
        let configuration = Configuration.default

        XCTAssertEqual(configuration.defaultPowerLevel, .medium)
        XCTAssertEqual(configuration.preferredLanguages, ["en", "fr", "ar"])
        XCTAssertNil(configuration.preferredLanguage)
        XCTAssertFalse(configuration.showInternalMenu)
        XCTAssertEqual(configuration.author.name, "John Doe")
        XCTAssertEqual(configuration.author.email, "no-reply@example.com")

    }

    func testDecode() throws {
        let data = Data("""
        {
          "defaultPowerLevel": 2,
          "preferredLanguages": ["es", "fr"],
          "preferredLanguage": "es",
          "showInternalMenu": true,
          "author": {
            "name": "Liam Nichols",
          }
        }
        """.utf8)

        let configuration = try Configuration.parse(data)

        XCTAssertEqual(configuration.defaultPowerLevel, .high)
        XCTAssertEqual(configuration.preferredLanguages, ["es", "fr"])
        XCTAssertEqual(configuration.preferredLanguage, "es")
        XCTAssertTrue(configuration.showInternalMenu)
        XCTAssertEqual(configuration.author.name, "Liam Nichols")
        XCTAssertEqual(configuration.author.email, "no-reply@example.com")
    }

    func testIssueDetection() throws {
        let data = Data("""
        {
          "defaultPowerlevel": 0,
          "preferredLanguage": "es",
          "author": {
            "isActive": true
          }
        }
        """.utf8)

        var recordedIssues: [Issue] = []
        _ = try Configuration.parse(data) { issue in
            recordedIssues.append(issue)
        }

        XCTAssertEqual(Set(recordedIssues.map(\.description)), [
            "Found unexpected property ‘defaultPowerlevel‘ while decoding.",
            "Property ‘preferredLanguage‘ is deprecated. Replaced by ‘preferredLanguages‘",
            "Found unexpected property ‘isActive‘ (in ‘author‘) while decoding."
        ])
    }

    func testOverride() throws {
        let data = Data("""
        {
          "defaultPowerLevel": 0,
          "author": {
            "name": "In the file"
          }
        }
        """.utf8)

        let overrides: [OptionOverride] = [
            #"defaultPowerLevel=2"#,
            #"author.name="Foo""#,
            #"preferredLanguages=["en"]"#,
            #"unknownProperty=false"#
        ]

        var recordedIssues: [Issue] = []
        let configuration = try Configuration.parse(data, overrides: overrides) { issue in
            recordedIssues.append(issue)
        }

        XCTAssertEqual(configuration.defaultPowerLevel, .high)
        XCTAssertEqual(configuration.author.name, "Foo")
        XCTAssertEqual(configuration.preferredLanguages, ["en"])

        XCTAssertEqual(Set(recordedIssues.map(\.description)), [
            "Found unexpected property ‘unknownProperty‘ while decoding."
        ])
    }
}

extension OptionOverride: ExpressibleByStringLiteral {
    public init(stringLiteral value: StaticString) {
        self = OptionOverride(String(describing: value))!
    }
}
