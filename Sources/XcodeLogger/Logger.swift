import Foundation

public final class Logger: @unchecked Sendable {
    public static let shared = Logger(
        configuration: LoggerConfiguration(subsystem: Bundle.main.bundleIdentifier ?? "XcodeLogger")
            .applyingEnvironment(ProcessInfo.processInfo.environment)
    )

    private let core: LoggerCore
    private let context: LoggerContext

    public init(configuration: LoggerConfiguration) {
        self.core = LoggerCore(configuration: configuration)
        self.context = LoggerContext()
    }

    private init(core: LoggerCore, context: LoggerContext) {
        self.core = core
        self.context = context
    }

    public var configuration: LoggerConfiguration {
        core.configuration
    }

    public func updateConfiguration(_ mutate: (inout LoggerConfiguration) -> Void) {
        core.updateConfiguration(mutate)
    }

    public func category(_ category: LoggerCategory) -> Logger {
        Logger(core: core, context: context.with(category: category))
    }

    public func scoped(metadata: LoggerMetadata) -> Logger {
        Logger(core: core, context: context.with(metadata: metadata))
    }

    public func scoped(subsystem: String) -> Logger {
        Logger(core: core, context: context.with(subsystem: subsystem))
    }

    public func scoped(
        category: LoggerCategory? = nil,
        metadata: LoggerMetadata = [:],
        subsystem: String? = nil
    ) -> Logger {
        Logger(core: core, context: context.merging(category: category, metadata: metadata, subsystem: subsystem))
    }

    public func log(
        level: LoggerLevel,
        category: LoggerCategory = .default,
        message: @autoclosure () -> String,
        metadata: LoggerMetadata = [:],
        source: LogSource = LogSource()
    ) {
        let runtime = core.runtimeConfiguration
        guard runtime.configuration.isEnabled else {
            return
        }

        let resolvedEvent = resolveEvent(
            level: level,
            category: category,
            message: message(),
            metadata: metadata,
            source: source,
            configuration: runtime.configuration
        )

        guard runtime.globalPolicy.accepts(event: resolvedEvent) else {
            return
        }

        var renderedPlain: String?
        var renderedANSI: String?

        for sink in runtime.sinks where sink.accepts(event: resolvedEvent, clock: runtime.configuration.clock, randomNumberGenerator: runtime.configuration.randomNumberGenerator) {
            let rendered: String
            if sink.supportsANSIColors {
                if let cached = renderedANSI {
                    rendered = cached
                } else {
                    let value = core.formatter.render(event: resolvedEvent.logEvent, configuration: runtime.configuration, includeANSI: true)
                    renderedANSI = value
                    rendered = value
                }
            } else {
                if let cached = renderedPlain {
                    rendered = cached
                } else {
                    let value = core.formatter.render(event: resolvedEvent.logEvent, configuration: runtime.configuration, includeANSI: false)
                    renderedPlain = value
                    rendered = value
                }
            }

            switch sink.deliveryMode {
            case .synchronous:
                sink.write(event: resolvedEvent.logEvent, rendered: rendered)
            case let .asynchronous(batchSize):
                core.deliveryCoordinator.enqueue(
                    sink: sink,
                    batchSize: max(1, batchSize),
                    event: resolvedEvent.logEvent,
                    rendered: rendered
                )
            }
        }
    }
}

extension Logger {
    private func resolveEvent(
        level: LoggerLevel,
        category: LoggerCategory,
        message: String,
        metadata: LoggerMetadata,
        source: LogSource,
        configuration: LoggerConfiguration
    ) -> ResolvedLogEvent {
        let resolvedCategory = context.category ?? (category == .default ? .default : category)
        let effectiveCategory = category == .default ? (context.category ?? .default) : category
        var resolvedMetadata = context.metadata
        for (key, value) in metadata {
            resolvedMetadata[key] = value
        }

        for rule in configuration.metadataRedactionRules {
            if resolvedMetadata[rule.key] != nil {
                resolvedMetadata[rule.key] = rule.replacement
            }
        }

        let resolvedMessage = configuration.messageRedactors.reduce(message) { partialResult, redactor in
            redactor.sanitize(partialResult)
        }

        let event = LogEvent(
            timestamp: configuration.clock.now(),
            subsystem: context.subsystem ?? configuration.subsystem,
            level: level,
            category: effectiveCategory == .default ? resolvedCategory : effectiveCategory,
            message: resolvedMessage,
            metadata: resolvedMetadata,
            source: source
        )
        return ResolvedLogEvent(logEvent: event)
    }
}

private final class LoggerCore: @unchecked Sendable {
    let formatter = LoggerFormatter()
    let deliveryCoordinator = LoggerDeliveryCoordinator()

    private let lock = NSLock()
    private var configurationStorage: LoggerConfiguration
    private var runtimeConfigurationStorage: LoggerRuntimeConfiguration

    init(configuration: LoggerConfiguration) {
        self.configurationStorage = configuration
        self.runtimeConfigurationStorage = LoggerRuntimeConfiguration(configuration: configuration)
    }

    var configuration: LoggerConfiguration {
        lock.lock()
        defer { lock.unlock() }
        return configurationStorage
    }

    var runtimeConfiguration: LoggerRuntimeConfiguration {
        lock.lock()
        defer { lock.unlock() }
        return runtimeConfigurationStorage
    }

    func updateConfiguration(_ mutate: (inout LoggerConfiguration) -> Void) {
        lock.lock()
        mutate(&configurationStorage)
        runtimeConfigurationStorage = LoggerRuntimeConfiguration(configuration: configurationStorage)
        lock.unlock()
    }
}

private struct LoggerContext: Sendable {
    var category: LoggerCategory?
    var metadata: LoggerMetadata = [:]
    var subsystem: String?

    func with(category: LoggerCategory) -> LoggerContext {
        var copy = self
        copy.category = category
        return copy
    }

    func with(metadata: LoggerMetadata) -> LoggerContext {
        var copy = self
        for (key, value) in metadata {
            copy.metadata[key] = value
        }
        return copy
    }

    func with(subsystem: String) -> LoggerContext {
        var copy = self
        copy.subsystem = subsystem
        return copy
    }

    func merging(category: LoggerCategory?, metadata: LoggerMetadata, subsystem: String?) -> LoggerContext {
        var copy = self
        if let category {
            copy.category = category
        }
        for (key, value) in metadata {
            copy.metadata[key] = value
        }
        if let subsystem {
            copy.subsystem = subsystem
        }
        return copy
    }
}

private struct ResolvedLogEvent: Sendable {
    let logEvent: LogEvent
}

private struct LoggerRuntimeConfiguration: Sendable {
    let configuration: LoggerConfiguration
    let globalPolicy: CompiledLoggerPolicy
    let sinks: [ResolvedSink]

    init(configuration: LoggerConfiguration) {
        self.configuration = configuration
        self.globalPolicy = CompiledLoggerPolicy(
            minimumLevel: configuration.minimumLevel,
            enabledCategories: configuration.enabledCategories,
            categoryLevels: configuration.categoryLevels,
            allowedLevelsByFile: configuration.allowedLevelsByFile,
            globalAllowedLevels: configuration.globalAllowedLevels,
            categoryRules: configuration.categoryRules,
            rateLimitRules: [],
            samplingRules: []
        )
        self.sinks = configuration.sinks.map(ResolvedSink.init)
    }
}

private struct CompiledCategoryRule: Sendable {
    let regularExpression: NSRegularExpression
    let mode: LoggerCategoryRule.MatchMode
}

private struct CompiledLoggerPolicy: Sendable {
    let minimumLevel: LoggerLevel?
    let enabledCategories: Set<LoggerCategory>?
    let categoryLevels: [LoggerCategory: LoggerLevel]
    let allowedLevelsByFile: [String: Set<LoggerLevel>]
    let globalAllowedLevels: Set<LoggerLevel>?
    let categoryRules: [CompiledCategoryRule]
    let rateLimitRules: [LoggerRateLimitRule]
    let samplingRules: [LoggerSamplingRule]

    init(
        minimumLevel: LoggerLevel?,
        enabledCategories: Set<LoggerCategory>?,
        categoryLevels: [LoggerCategory: LoggerLevel],
        allowedLevelsByFile: [String: Set<LoggerLevel>],
        globalAllowedLevels: Set<LoggerLevel>?,
        categoryRules: [LoggerCategoryRule],
        rateLimitRules: [LoggerRateLimitRule],
        samplingRules: [LoggerSamplingRule]
    ) {
        self.minimumLevel = minimumLevel
        self.enabledCategories = enabledCategories
        self.categoryLevels = categoryLevels
        self.allowedLevelsByFile = allowedLevelsByFile
        self.globalAllowedLevels = globalAllowedLevels
        self.categoryRules = categoryRules.compactMap { rule in
            do {
                return CompiledCategoryRule(
                    regularExpression: try NSRegularExpression(pattern: rule.pattern),
                    mode: rule.mode
                )
            } catch {
                #if DEBUG
                fputs("XcodeLogger ignored invalid category rule regex: \(rule.pattern)\n", stderr)
                #endif
                return nil
            }
        }
        self.rateLimitRules = rateLimitRules
        self.samplingRules = samplingRules
    }

    func accepts(event: ResolvedLogEvent) -> Bool {
        acceptsBase(event: event.logEvent)
    }

    func acceptsBase(event: LogEvent) -> Bool {
        if let enabledCategories, !enabledCategories.contains(event.category) {
            return false
        }

        if categoryRuleBlocks(category: event.category) {
            return false
        }

        if let allowed = allowedLevelsByFile[event.source.fileName.uppercased()] {
            return allowed.contains(event.level)
        }

        if let globalAllowedLevels {
            return globalAllowedLevels.contains(event.level)
        }

        let threshold = categoryLevels[event.category] ?? minimumLevel ?? .simple
        return event.level >= threshold
    }

    private func categoryRuleBlocks(category: LoggerCategory) -> Bool {
        guard !categoryRules.isEmpty else {
            return false
        }

        let text = category.rawValue
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        var matchedAllow = false
        var hasAllowRule = false

        for rule in categoryRules {
            let matched = rule.regularExpression.firstMatch(in: text, range: range) != nil
            switch rule.mode {
            case .allow:
                hasAllowRule = true
                matchedAllow = matchedAllow || matched
            case .deny:
                if matched {
                    return true
                }
            }
        }

        return hasAllowRule && !matchedAllow
    }
}

private final class ResolvedSink: @unchecked Sendable {
    let sink: LoggerSink
    let supportsANSIColors: Bool
    let deliveryMode: LoggerSinkDeliveryMode
    private let policy: CompiledLoggerPolicy
    private let lock = NSLock()
    private var rateLimitState: [String: RateLimitState] = [:]

    init(sink: LoggerSink) {
        self.sink = sink
        self.supportsANSIColors = sink.supportsANSIColors
        if let configurable = sink as? LoggerConfigurableSink {
            self.deliveryMode = configurable.deliveryMode
            self.policy = CompiledLoggerPolicy(
                minimumLevel: configurable.policy.minimumLevel,
                enabledCategories: configurable.policy.enabledCategories,
                categoryLevels: configurable.policy.categoryLevels,
                allowedLevelsByFile: configurable.policy.allowedLevelsByFile,
                globalAllowedLevels: configurable.policy.globalAllowedLevels,
                categoryRules: configurable.policy.categoryRules,
                rateLimitRules: configurable.policy.rateLimitRules,
                samplingRules: configurable.policy.samplingRules
            )
        } else {
            self.deliveryMode = .synchronous
            self.policy = CompiledLoggerPolicy(
                minimumLevel: nil,
                enabledCategories: nil,
                categoryLevels: [:],
                allowedLevelsByFile: [:],
                globalAllowedLevels: nil,
                categoryRules: [],
                rateLimitRules: [],
                samplingRules: []
            )
        }
    }

    func accepts(event: ResolvedLogEvent, clock: any LoggerClock, randomNumberGenerator: any LoggerRandomNumberGenerator) -> Bool {
        guard policy.acceptsBase(event: event.logEvent) else {
            return false
        }

        lock.lock()
        defer { lock.unlock() }

        for rule in policy.rateLimitRules where rule.category == nil || rule.category == event.logEvent.category {
            let key = rule.category?.rawValue ?? "*"
            let now = clock.now()
            var state = rateLimitState[key] ?? RateLimitState(windowStart: now, emittedCount: 0)
            if now.timeIntervalSince(state.windowStart) >= rule.window {
                state = RateLimitState(windowStart: now, emittedCount: 0)
            }
            guard state.emittedCount < rule.maximumEvents else {
                rateLimitState[key] = state
                return false
            }
            state.emittedCount += 1
            rateLimitState[key] = state
        }

        for rule in policy.samplingRules where rule.category == event.logEvent.category {
            if randomNumberGenerator.nextUnitInterval() > rule.probability {
                return false
            }
        }

        return true
    }

    func write(event: LogEvent, rendered: String) {
        sink.write(event: event, rendered: rendered)
    }
}

private struct RateLimitState {
    var windowStart: Date
    var emittedCount: Int
}

private final class LoggerDeliveryCoordinator: @unchecked Sendable {
    private let queue = DispatchQueue(label: "com.codefi.xcodelogger.delivery")
    private var pending: [DeliveryEnvelope] = []
    private var scheduled = false

    func enqueue(sink: ResolvedSink, batchSize: Int, event: LogEvent, rendered: String) {
        queue.async {
            self.pending.append(DeliveryEnvelope(sink: sink, batchSize: batchSize, event: event, rendered: rendered))
            guard !self.scheduled else {
                return
            }
            self.scheduled = true
            self.queue.async {
                self.drain()
            }
        }
    }

    private func drain() {
        let envelopes = pending
        pending.removeAll(keepingCapacity: true)
        scheduled = false

        for envelope in envelopes {
            _ = envelope.batchSize
            envelope.sink.write(event: envelope.event, rendered: envelope.rendered)
        }

        if !pending.isEmpty {
            scheduled = true
            queue.async {
                self.drain()
            }
        }
    }
}

private struct DeliveryEnvelope {
    let sink: ResolvedSink
    let batchSize: Int
    let event: LogEvent
    let rendered: String
}
