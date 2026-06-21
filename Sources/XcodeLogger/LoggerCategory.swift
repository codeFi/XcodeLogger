import Foundation

public struct LoggerCategory: Hashable, RawRepresentable, ExpressibleByStringLiteral, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: StringLiteralType) {
        self.rawValue = value
    }

    public static let `default`: LoggerCategory = "default"
    public static let debug: LoggerCategory = "debug"
    public static let development: LoggerCategory = "development"
    public static let debugDevelopment: LoggerCategory = "debug-development"
    public static let online: LoggerCategory = "online"
}

extension LoggerCategory {
    init(legacyType: XLOGGER_TYPE) {
        switch legacyType {
        case .NSLogReplacement:
            self = .default
        case .debug:
            self = .debug
        case .development:
            self = .development
        case .debugDevelopment:
            self = .debugDevelopment
        case .onlineServices:
            self = .online
        case .all:
            self = .default
        }
    }
}
