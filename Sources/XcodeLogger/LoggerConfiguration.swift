import Foundation

public struct LoggerConfiguration {
    public var subsystem: String
    public var enabledCategories: Set<LoggerCategory>?
    public var minimumLevel: LoggerLevel
    public var categoryLevels: [LoggerCategory: LoggerLevel]
    public var allowedLevelsByFile: [String: Set<LoggerLevel>]
    public var globalAllowedLevels: Set<LoggerLevel>?
    public var theme: LoggerTheme
    public var formatting: LoggerFormatting
    public var sinks: [LoggerSink]
    public var includeSourceMetadata: Bool

    public init(
        subsystem: String,
        enabledCategories: Set<LoggerCategory>? = nil,
        minimumLevel: LoggerLevel = .simple,
        categoryLevels: [LoggerCategory: LoggerLevel] = [:],
        allowedLevelsByFile: [String: Set<LoggerLevel>] = [:],
        globalAllowedLevels: Set<LoggerLevel>? = nil,
        theme: LoggerTheme = .defaultLight,
        formatting: LoggerFormatting = LoggerFormatting(),
        sinks: [LoggerSink]? = nil,
        includeSourceMetadata: Bool = true
    ) {
        self.subsystem = subsystem
        self.enabledCategories = enabledCategories
        self.minimumLevel = minimumLevel
        self.categoryLevels = categoryLevels
        self.allowedLevelsByFile = allowedLevelsByFile
        self.globalAllowedLevels = globalAllowedLevels
        self.theme = theme
        self.formatting = formatting
        self.sinks = sinks ?? [
            OSLogSink(subsystem: subsystem),
            DebugConsoleSink(supportsANSIColors: Self.isANSISupportedByEnvironment())
        ]
        self.includeSourceMetadata = includeSourceMetadata
    }

    public func applyingEnvironment(_ environment: [String: String]) -> LoggerConfiguration {
        var copy = self

        if let minimum = environment["XCODELOGGER_LEVEL"]?.lowercased() {
            let mapping: [String: LoggerLevel] = [
                "simple": .simple,
                "simple-no-header": .simpleNoHeader,
                "info": .information,
                "information": .information,
                "important": .important,
                "warning": .warning,
                "error": .error
            ]
            if let level = mapping[minimum] {
                copy.minimumLevel = level
            }
        }

        if let categories = environment["XCODELOGGER_CATEGORIES"]?.split(separator: ",") {
            copy.enabledCategories = Set(categories.map { LoggerCategory(rawValue: $0.trimmingCharacters(in: .whitespacesAndNewlines)) })
        }

        if let ansiValue = environment["XCODELOGGER_ANSI"]?.lowercased() {
            let enableANSI = ansiValue == "1" || ansiValue == "true" || ansiValue == "yes"
            copy.sinks = copy.sinks.map { sink in
                if sink is DebugConsoleSink {
                    return DebugConsoleSink(supportsANSIColors: enableANSI) as LoggerSink
                }
                if sink is StdoutSink {
                    return StdoutSink(supportsANSIColors: enableANSI) as LoggerSink
                }
                return sink
            }
        }

        return copy
    }
}

extension LoggerConfiguration {
    static func isANSISupportedByEnvironment(environment: [String: String] = ProcessInfo.processInfo.environment) -> Bool {
        if isRunningInXcode(environment: environment) {
            return false
        }
        if let term = environment["TERM"], term != "dumb" {
            return true
        }
        return environment["XCODE_COLORS"] == "YES"
    }

    static func isRunningInXcode(environment: [String: String] = ProcessInfo.processInfo.environment) -> Bool {
        let markers = [
            "XCODE_VERSION_ACTUAL",
            "__XCODE_BUILT_PRODUCTS_DIR_PATHS",
            "IDE_DISABLED_OS_ACTIVITY_DT_MODE",
            "OS_ACTIVITY_DT_MODE"
        ]
        return markers.contains(where: { environment[$0] != nil })
    }
}
