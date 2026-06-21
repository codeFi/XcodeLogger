import Foundation

@objc public final class XcodeLogger: NSObject {
    @objc(sharedManager)
    public static let shared = XcodeLogger()

    private let logger = Logger.shared
    private let stateLock = NSLock()
    private var legacyDescriptions: [LegacyKey: String] = [:]
    private var customHeaders: [LegacyKey: [HeaderToken]] = [:]

    private override init() {
        super.init()
        logger.updateConfiguration { configuration in
            configuration.theme = .defaultLight
        }
    }

    @objc public func setInfoPlistKeyNameForRunningSchemes(_ key: String) {
        _ = key
    }

    @objc public func setBuildSchemeName(_ schemeName: String, forXLogType logType: XLOGGER_TYPE) {
        _ = schemeName
        _ = logType
    }

    @objc public func filterXLogLevels(_ logLevels: [NSNumber], forFileName fileName: String?) {
        let levels = Set(logLevels.compactMap { LoggerLevel(legacyLevel: XLOGGER_LEVEL(rawValue: $0.uint32Value) ?? .simple) })
        logger.updateConfiguration { configuration in
            if let fileName {
                configuration.allowedLevelsByFile[fileName.uppercased()] = levels
            } else {
                configuration.globalAllowedLevels = levels
            }
        }
    }

    @objc public func setHeaderForXLogType(_ logType: XLOGGER_TYPE, level logLevel: XLOGGER_LEVEL, format headerFormat: String, arguments: [Any]) {
        let tokens = Self.tokens(from: headerFormat, arguments: arguments)

        stateLock.lock()
        for key in expandedKeys(for: logType, level: logLevel) {
            customHeaders[key] = tokens
        }
        stateLock.unlock()
    }

    @objc public func setLogHeaderDescription(_ description: String, forLogType logType: XLOGGER_TYPE, level logLevel: XLOGGER_LEVEL) {
        stateLock.lock()
        for key in expandedKeys(for: logType, level: logLevel) {
            legacyDescriptions[key] = description
        }
        stateLock.unlock()
    }

    @objc public func setNumberOfNewLinesAfterHeader(_ count: UInt, forXLogType logType: XLOGGER_TYPE, level logLevel: XLOGGER_LEVEL) {
        let separator = count == 0 ? " " : String(repeating: "\n", count: Int(count))
        logger.updateConfiguration { configuration in
            configuration.formatting.lineSeparatorAfterHeader = separator
        }
        _ = logType
        _ = logLevel
    }

    @objc public func setNumberOfNewLinesAfterOutput(_ count: UInt, forXLogType logType: XLOGGER_TYPE, level logLevel: XLOGGER_LEVEL) {
        logger.updateConfiguration { configuration in
            configuration.formatting.lineSeparatorAfterMessage = String(repeating: "\n", count: Int(count))
        }
        _ = logType
        _ = logLevel
    }

    @objc public func setTimestampFormat(_ format: String) {
        logger.updateConfiguration { configuration in
            configuration.formatting.timestampFormat = format
        }
    }

    @objc public func setColorLogsEnabled(_ enabled: Bool) {
        logger.updateConfiguration { configuration in
            configuration.sinks = configuration.sinks.map { sink in
                if sink is DebugConsoleSink {
                    return DebugConsoleSink(supportsANSIColors: enabled) as LoggerSink
                }
                return sink
            }
        }
    }

    @objc public func availableColorThemes() -> [String] {
        Array(LoggerTheme.all.keys).sorted()
    }

    @objc public func loadColorThemeWithName(_ colorThemeName: String) {
        guard let theme = LoggerTheme.all[colorThemeName.uppercased()] else {
            return
        }
        logger.updateConfiguration { configuration in
            configuration.theme = theme
        }
    }

    @objc public func printAvailableColorThemes() {
        logger.log(level: .simpleNoHeader, category: .default, message: availableColorThemes().joined(separator: "\n"))
    }

    @objc public func printColorThemeCreationInstructions() {
        logger.log(level: .simpleNoHeader, category: .default, message: "Create a LoggerTheme and assign it through LoggerConfiguration or loadColorThemeWithName(_:).")
    }

    @objc(emitCompatibilityLogWithType:level:file:function:line:message:metadata:)
    public func emitCompatibilityLog(
        type: XLOGGER_TYPE,
        level: XLOGGER_LEVEL,
        file: String,
        function: String,
        line: Int,
        message: String,
        metadata: LoggerMetadata = [:]
    ) {
        let key = LegacyKey(type: type, level: level)
        let category = LoggerCategory(legacyType: type)
        let modernLevel = LoggerLevel(legacyLevel: level)
        let source = LogSource(file: file, function: function, line: line)

        var label: String?
        var tokens: [HeaderToken]?

        stateLock.lock()
        label = legacyDescriptions[key]
        tokens = customHeaders[key]
        stateLock.unlock()

        logger.updateConfiguration { configuration in
            let resolvedLabel = label ?? configuration.theme.entry(for: modernLevel).label
            configuration.formatting.headerTokens = tokens ?? defaultTokens(with: resolvedLabel)
        }

        logger.log(level: modernLevel, category: category, message: message, metadata: metadata, source: source)
    }
}

extension XcodeLogger: @unchecked Sendable {}

extension XcodeLogger {
    private func defaultTokens(with label: String) -> [HeaderToken] {
        [
            .literal("["),
            .literal(label),
            .literal("] "),
            .timestamp,
            .literal(" "),
            .file,
            .literal(":"),
            .line,
            .literal(" "),
            .function
        ]
    }

    private func expandedKeys(for logType: XLOGGER_TYPE, level: XLOGGER_LEVEL) -> [LegacyKey] {
        let types: [XLOGGER_TYPE] = logType == .all ? [.NSLogReplacement, .debug, .development, .debugDevelopment, .onlineServices] : [logType]
        let levels: [XLOGGER_LEVEL] = level == .all ? [.simple, .simpleNoHeader, .information, .important, .warning, .error] : [level]
        return types.flatMap { type in levels.map { LegacyKey(type: type, level: $0) } }
    }

    private static func tokens(from format: String, arguments: [Any]) -> [HeaderToken] {
        let pieces = format.components(separatedBy: "%@")
        var tokens: [HeaderToken] = []

        for (index, piece) in pieces.enumerated() {
            if !piece.isEmpty {
                tokens.append(.literal(piece))
            }

            guard index < arguments.count else {
                continue
            }

            let argument = arguments[index]
            if let number = argument as? NSNumber, let legacyArgument = XLOGGER_ARGS(rawValue: number.uint32Value) {
                switch legacyArgument {
                case .logDescription:
                    tokens.append(.label)
                case .timestamp:
                    tokens.append(.timestamp)
                case .callee:
                    tokens.append(.literal("self"))
                case .calleeMethod:
                    tokens.append(.function)
                case .lineNumber:
                    tokens.append(.line)
                case .fileName:
                    tokens.append(.file)
                }
            } else if let string = argument as? String {
                tokens.append(.literal(string))
            }
        }

        return tokens
    }
}

private struct LegacyKey: Hashable {
    let type: XLOGGER_TYPE
    let level: XLOGGER_LEVEL
}
