import Foundation

public enum Availability {
    case available
    case deprecated(String = "")

    public static var deprecated: Availability { .deprecated() }
}
