import Foundation

public enum Availability {
    /// Treats the option as a regular  property that can be decoded without any issue.
    case available

    /// Records an issue if the option is seen in the source data during parsing.
    ///
    /// You can later use the recorded issue to log a message or throw an error that helps instruct the user how to migrate.
    case deprecated(String = "")

    /// Records an issue if the option is seen in the source data during parsing.
    public static var deprecated: Availability { .deprecated() }
}
