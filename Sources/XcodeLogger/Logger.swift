import Foundation

public final class Logger: @unchecked Sendable {
    public static let shared = Logger(
        configuration: LoggerConfiguration(subsystem: Bundle.main.bundleIdentifier ?? "XcodeLogger")
            .applyingEnvironment(ProcessInfo.processInfo.environment)
    )

    private let formatter = LoggerFormatter()
    private let lock = NSLock()
    private var configurationStorage: LoggerConfiguration

    public init(configuration: LoggerConfiguration) {
        self.configurationStorage = configuration
    }

    public var configuration: LoggerConfiguration {
        lock.lock()
        defer { lock.unlock() }
        return configurationStorage
    }

    public func updateConfiguration(_ mutate: (inout LoggerConfiguration) -> Void) {
        lock.lock()
        mutate(&configurationStorage)
        lock.unlock()
    }

    public func log(
        level: LoggerLevel,
        category: LoggerCategory = .default,
        message: @autoclosure () -> String,
        metadata: LoggerMetadata = [:],
        source: LogSource = LogSource()
    ) {
        let configuration = self.configuration
        let event = LogEvent(
            level: level,
            category: category,
            message: message(),
            metadata: metadata,
            source: source
        )

        guard shouldLog(event: event, configuration: configuration) else {
            return
        }

        for sink in configuration.sinks {
            let rendered = formatter.render(
                event: event,
                configuration: configuration,
                includeANSI: sink.supportsANSIColors
            )
            sink.write(event: event, rendered: rendered)
        }
    }
}

extension Logger {
    private func shouldLog(event: LogEvent, configuration: LoggerConfiguration) -> Bool {
        if let enabledCategories = configuration.enabledCategories, !enabledCategories.contains(event.category) {
            return false
        }

        if let allowed = configuration.allowedLevelsByFile[event.source.fileName.uppercased()] {
            return allowed.contains(event.level)
        }

        if let globalAllowedLevels = configuration.globalAllowedLevels {
            return globalAllowedLevels.contains(event.level)
        }

        let minimumLevel = configuration.categoryLevels[event.category] ?? configuration.minimumLevel
        return event.level >= minimumLevel
    }
}
