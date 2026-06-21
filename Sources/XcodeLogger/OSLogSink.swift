import OSLog

public final class OSLogSink: LoggerSink {
    public let supportsANSIColors = false

    private let loggerFactory: @Sendable (LoggerCategory) -> os.Logger

    public init(subsystem: String) {
        self.loggerFactory = { category in
            os.Logger(subsystem: subsystem, category: category.rawValue)
        }
    }

    public func write(event: LogEvent, rendered: String) {
        let logger = loggerFactory(event.category)
        logger.log(level: event.level.osLogType, "\(rendered, privacy: .public)")
    }
}
