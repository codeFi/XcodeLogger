import Foundation

public struct LoggerConfiguration: @unchecked Sendable {
    public var subsystem: String
    public var isEnabled: Bool
    public var enabledCategories: Set<LoggerCategory>?
    public var minimumLevel: LoggerLevel
    public var categoryLevels: [LoggerCategory: LoggerLevel]
    public var allowedLevelsByFile: [String: Set<LoggerLevel>]
    public var globalAllowedLevels: Set<LoggerLevel>?
    public var categoryRules: [LoggerCategoryRule]
    public var metadataRedactionRules: [LoggerMetadataRedactionRule]
    public var messageRedactors: [LoggerMessageRedactor]
    public var theme: LoggerTheme
    public var formatting: LoggerFormatting
    public var sinks: [LoggerSink]
    public var includeSourceMetadata: Bool
    public var clock: any LoggerClock
    public var randomNumberGenerator: any LoggerRandomNumberGenerator

    public init(
        subsystem: String,
        isEnabled: Bool = true,
        enabledCategories: Set<LoggerCategory>? = nil,
        minimumLevel: LoggerLevel = .simple,
        categoryLevels: [LoggerCategory: LoggerLevel] = [:],
        allowedLevelsByFile: [String: Set<LoggerLevel>] = [:],
        globalAllowedLevels: Set<LoggerLevel>? = nil,
        categoryRules: [LoggerCategoryRule] = [],
        metadataRedactionRules: [LoggerMetadataRedactionRule] = [],
        messageRedactors: [LoggerMessageRedactor] = [],
        theme: LoggerTheme = .defaultLight,
        formatting: LoggerFormatting = LoggerFormatting(),
        sinks: [LoggerSink]? = nil,
        includeSourceMetadata: Bool = true,
        clock: any LoggerClock = SystemLoggerClock(),
        randomNumberGenerator: any LoggerRandomNumberGenerator = SystemLoggerRandomNumberGenerator()
    ) {
        self.subsystem = subsystem
        self.isEnabled = isEnabled
        self.enabledCategories = enabledCategories
        self.minimumLevel = minimumLevel
        self.categoryLevels = categoryLevels
        self.allowedLevelsByFile = allowedLevelsByFile
        self.globalAllowedLevels = globalAllowedLevels
        self.categoryRules = categoryRules
        self.metadataRedactionRules = metadataRedactionRules
        self.messageRedactors = messageRedactors
        self.theme = theme
        self.formatting = formatting
        self.sinks = sinks ?? [
            OSLogSink(subsystem: subsystem),
            DebugConsoleSink(supportsANSIColors: Self.isANSISupportedByEnvironment())
        ]
        self.includeSourceMetadata = includeSourceMetadata
        self.clock = clock
        self.randomNumberGenerator = randomNumberGenerator
    }

    public func whenEnabled(_ enabled: Bool) -> LoggerConfiguration {
        var copy = self
        copy.isEnabled = enabled
        return copy
    }

    public func applyingBuildConfiguration<Provider: LoggerBuildConfigurationProviding>(_ provider: Provider.Type) -> LoggerConfiguration {
        whenEnabled(provider.isLoggingEnabled)
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
                if let sink = sink as? DebugConsoleSink {
                    sink.supportsANSIColors = enableANSI
                    return sink
                }
                if let sink = sink as? StdoutSink {
                    sink.supportsANSIColors = enableANSI
                    return sink
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
