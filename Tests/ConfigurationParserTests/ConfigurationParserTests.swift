import ConfigurationParser
import XCTest

final class ConfigurationParserTests: XCTestCase {
    struct Configuration: ParsableConfiguration {
        enum Power: Int, Decodable {
            case low, medium, high
        }

        @Option(documentation: "The power level used if not otherwise specified.")
        var defaultPowerLevel: Power = .medium

        @Option(documentation: "Array of preferred spoken languages")
        var preferredLanguages: [String] = ["en", "fr", "ar"]

        @Option(
            availability: .deprecated("Replaced by ‘preferredLanguages‘"),
            documentation: Documentation(
                hidden: true,
                summary: "The preferred spoken language"
            )
        )
        var preferredLanguage: String? = nil

        var showInternalMenu: Bool = false

        @Option(documentation: "Details of the author used when creating commits")
        var author: Author

        struct Author: ParsableConfiguration {
            @Option(documentation: "The full name of the author")
            var name: String = "John Doe"

            @Option(documentation: "The email address of the author")
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

        let configuration = try Configuration.parse(using: data)

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
        _ = try Configuration.parse(using: data) { issue in
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
            #"defaultPowerLevel: 2          "#,
            #"author.name: "Foo"            "#,
            #"preferredLanguages: ["en"]    "#,
            #"unknownProperty: false        "#
        ]

        var recordedIssues: [Issue] = []
        let configuration = try Configuration.parse(using: data, overrides: overrides) { issue in
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
