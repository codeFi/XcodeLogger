import OSLog

@objc public enum LoggerLevel: Int, CaseIterable, Comparable, Sendable {
    case simple = 10
    case simpleNoHeader = 11
    case information = 12
    case important = 13
    case warning = 14
    case error = 15

    public static func < (lhs: LoggerLevel, rhs: LoggerLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension LoggerLevel {
    var osLogType: OSLogType {
        switch self {
        case .simple, .simpleNoHeader:
            return .default
        case .information:
            return .info
        case .important:
            return .default
        case .warning:
            return .error
        case .error:
            return .fault
        }
    }

    var defaultLabel: String {
        switch self {
        case .simple, .simpleNoHeader:
            return "LOG"
        case .information:
            return "INFO"
        case .important:
            return "IMPORTANT"
        case .warning:
            return "WARNING"
        case .error:
            return "ERROR"
        }
    }

    init(legacyLevel: XLOGGER_LEVEL) {
        switch legacyLevel {
        case .simple:
            self = .simple
        case .simpleNoHeader:
            self = .simpleNoHeader
        case .information:
            self = .information
        case .important:
            self = .important
        case .warning:
            self = .warning
        case .error, .all:
            self = .error
        }
    }
}
