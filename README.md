# Swift Configuration Parser

Simple configuration file parsing for Swift.

## Usage

Start by declaring a type containing your configuration options:

```swift
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

    @Option(.deprecated("Replaced by ‘preferredLanguages‘"), hidden: true)
    var preferredLanguage: String? = nil

    @Option(summary: "Details of the author used when creating commits")
    var author: Author

    struct Author: ParsableConfiguration {
        @Option(summary: "The full name of the author")
        var name: String = "John Doe"

        @Option(summary: "The email address of the author")
        var email: String = "no-reply@example.com"
    }
}
```

Then use the static methods available through the `ParsableConfiguration` protocol to load your configuration from the appropriate source:

```swift
// The default configuration instance
let configuration = Configuration.default
```

```swift
// Load directly from a file
let fileURL = URL(fileURLWithPath: "./.options.json")
let configuration = try Configuration.parse(contentsOf: fileURL)
```

```swift
// Load from data
let data = try downloadConfigurationFromServer()
let configuration = try Configuration.parse(data)
```

## Features

- Preserve default values when deserializing
- Detect unexpected properties (typos/misconfiguration) while loading
- Flexible overrides
- Customizable decoding - Uses `JSONDecoder` by default but you can plug in anything

For an example, see [Example](./Example/).

---

Heavily inspired by [swift-argument-parser](https://github.com/apple/swift-argument-parser).
