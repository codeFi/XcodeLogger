import OSLog

public final class OSLogSink: LoggerSink, LoggerConfigurableSink {
    public var supportsANSIColors = false
    public var deliveryMode: LoggerSinkDeliveryMode
    public var policy: LoggerSinkPolicy

    private let defaultSubsystem: String
    private let loggerFactory: @Sendable (String, LoggerCategory) -> os.Logger

    public init(
        subsystem: String,
        deliveryMode: LoggerSinkDeliveryMode = .synchronous,
        policy: LoggerSinkPolicy = LoggerSinkPolicy()
    ) {
        self.defaultSubsystem = subsystem
        self.deliveryMode = deliveryMode
        self.policy = policy
        self.loggerFactory = { subsystem, category in
            os.Logger(subsystem: subsystem, category: category.rawValue)
        }
    }

    public func write(event: LogEvent, rendered: String) {
        let logger = loggerFactory(event.subsystem.isEmpty ? defaultSubsystem : event.subsystem, event.category)
        logger.log(level: event.level.osLogType, "\(rendered, privacy: .public)")
    }
}
