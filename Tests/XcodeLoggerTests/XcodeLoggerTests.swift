import XCTest
@testable import XcodeLogger

final class XcodeLoggerTests: XCTestCase {
    func testDisabledConfigurationSuppressesAllOutput() {
        let sink = RecordingSink()
        let logger = Logger(configuration: LoggerConfiguration(
            subsystem: "test",
            isEnabled: false,
            sinks: [sink]
        ))

        logger.log(level: .error, category: .default, message: "ignored")

        XCTAssertTrue(sink.messages.isEmpty)
    }

    func testBuildConfigurationProviderCanDisableLogging() {
        let sink = RecordingSink()
        let configuration = LoggerConfiguration(
            subsystem: "test",
            sinks: [sink]
        ).applyingBuildConfiguration(DisabledBuildConfiguration.self)
        let logger = Logger(configuration: configuration)

        logger.log(level: .error, category: .default, message: "ignored")

        XCTAssertFalse(configuration.isEnabled)
        XCTAssertTrue(sink.messages.isEmpty)
    }

    func testMinimumLevelFiltering() {
        let sink = RecordingSink()
        let logger = Logger(configuration: LoggerConfiguration(
            subsystem: "test",
            minimumLevel: .warning,
            sinks: [sink]
        ))

        logger.log(level: .information, category: .default, message: "ignored")
        logger.log(level: .error, category: .default, message: "kept")

        XCTAssertEqual(sink.messages.count, 1)
        XCTAssertTrue(sink.messages[0].contains("kept"))
    }

    func testCategoryFiltering() {
        let sink = RecordingSink()
        let logger = Logger(configuration: LoggerConfiguration(
            subsystem: "test",
            enabledCategories: [.debug],
            sinks: [sink]
        ))

        logger.log(level: .simple, category: .development, message: "ignored")
        logger.log(level: .simple, category: .debug, message: "kept")

        XCTAssertEqual(sink.events.map(\.category.rawValue), ["debug"])
    }

    func testMetadataCaptureAndStructuredRendering() {
        let formatter = LoggerFormatter()
        let event = LogEvent(
            level: .information,
            category: .debug,
            message: "hello",
            metadata: ["requestID": "123"],
            source: LogSource(file: "File.swift", function: "test()", line: 7)
        )

        let rendered = formatter.renderStructuredMessage(for: event)
        XCTAssertTrue(rendered.contains("requestID=123"))
        XCTAssertTrue(rendered.contains("hello"))
    }

    func testHeaderFormattingUsesCustomTokens() {
        let sink = RecordingSink()
        let logger = Logger(configuration: LoggerConfiguration(
            subsystem: "test",
            formatting: LoggerFormatting(
                timestampFormat: "yyyy",
                headerTokens: [.literal("<"), .category, .literal(">"), .line],
                lineSeparatorAfterHeader: " ",
                lineSeparatorAfterMessage: ""
            ),
            sinks: [sink]
        ))

        logger.log(level: .important, category: .networking, message: "body", source: LogSource(file: "File.swift", function: "demo()", line: 42))

        XCTAssertEqual(sink.messages.first, "<networking>42 body")
    }

    func testThemeResolutionAndANSIFormatting() {
        let sink = RecordingSink(supportsANSIColors: true)
        let logger = Logger(configuration: LoggerConfiguration(
            subsystem: "test",
            theme: .dracula,
            sinks: [sink]
        ))

        logger.log(level: .warning, category: .default, message: "colored")

        XCTAssertTrue(sink.messages[0].contains("\u{001B}["))
    }

    func testPlainTextFallbackWhenANSIDisabled() {
        let sink = RecordingSink(supportsANSIColors: false)
        let logger = Logger(configuration: LoggerConfiguration(
            subsystem: "test",
            theme: .dracula,
            sinks: [sink]
        ))

        logger.log(level: .warning, category: .default, message: "plain")

        XCTAssertFalse(sink.messages[0].contains("\u{001B}["))
    }

    func testStdoutSinkWritesRenderedOutputWithTrailingNewline() {
        let buffer = LockedStringBuffer()
        let sink = StdoutSink(supportsANSIColors: false) { message in
            buffer.append(message)
        }
        let logger = Logger(configuration: LoggerConfiguration(
            subsystem: "test",
            sinks: [sink]
        ))

        logger.log(level: .information, category: .default, message: "stdout")

        XCTAssertEqual(buffer.values.count, 1)
        XCTAssertTrue(buffer.values[0].contains("stdout"))
        XCTAssertTrue(buffer.values[0].hasSuffix("\n"))
    }

    func testCompatibilityMappingUsesCategoryBasedRouting() {
        let sink = RecordingSink()
        Logger.shared.updateConfiguration {
            $0.sinks = [sink]
            $0.minimumLevel = .simple
        }

        XcodeLogger.shared.emitCompatibilityLog(
            type: .development,
            level: .information,
            file: "Legacy.m",
            function: "-[Legacy test]",
            line: 8,
            message: "legacy"
        )

        XCTAssertEqual(sink.events.last?.category, .development)
        XCTAssertEqual(sink.events.last?.level, .information)
    }

    func testGlobalAllowedLevelsOverrideThresholdFiltering() {
        let sink = RecordingSink()
        let logger = Logger(configuration: LoggerConfiguration(
            subsystem: "test",
            minimumLevel: .error,
            globalAllowedLevels: [.warning],
            sinks: [sink]
        ))

        logger.log(level: .warning, category: .default, message: "allowed")
        logger.log(level: .error, category: .default, message: "blocked by explicit filter")

        XCTAssertEqual(sink.messages.count, 1)
        XCTAssertTrue(sink.messages[0].contains("allowed"))
    }

    func testEnvironmentOverrides() {
        let sink = RecordingSink()
        let configuration = LoggerConfiguration(subsystem: "test", sinks: [sink]).applyingEnvironment([
            "XCODELOGGER_LEVEL": "warning",
            "XCODELOGGER_CATEGORIES": "debug,networking",
            "XCODELOGGER_ANSI": "false"
        ])

        XCTAssertEqual(configuration.minimumLevel, .warning)
        XCTAssertEqual(configuration.enabledCategories, [.debug, .networking])
        let debugSink = try? XCTUnwrap(configuration.sinks.first as? RecordingSink)
        XCTAssertEqual(debugSink?.supportsANSIColors, false)
    }

    func testANSIDefaultIsDisabledWhenRunningInXcode() {
        let environment = [
            "TERM": "xterm-256color",
            "XCODE_VERSION_ACTUAL": "2650"
        ]

        XCTAssertTrue(LoggerConfiguration.isRunningInXcode(environment: environment))
        XCTAssertFalse(LoggerConfiguration.isANSISupportedByEnvironment(environment: environment))
    }

    func testConcurrentLoggingPreservesIsolatedMetadata() async {
        let sink = RecordingSink()
        let logger = Logger(configuration: LoggerConfiguration(subsystem: "test", sinks: [sink]))

        await withTaskGroup(of: Void.self) { group in
            for value in 0..<100 {
                group.addTask {
                    logger.log(
                        level: .information,
                        category: .debug,
                        message: "value \(value)",
                        metadata: ["id": "\(value)"],
                        source: LogSource(file: "Task.swift", function: "work()", line: value)
                    )
                }
            }
        }

        XCTAssertEqual(sink.events.count, 100)
        let identifiers = Set(sink.events.compactMap { $0.metadata["id"] })
        XCTAssertEqual(identifiers.count, 100)
    }

    func testPerformanceBaseline() {
        let sink = RecordingSink()
        let logger = Logger(configuration: LoggerConfiguration(subsystem: "test", sinks: [sink]))

        measure {
            for value in 0..<1_000 {
                logger.log(level: .simpleNoHeader, category: .default, message: "value \(value)")
            }
        }
    }
}

private final class RecordingSink: LoggerSink {
    let supportsANSIColors: Bool
    private let lock = NSLock()
    private(set) var messages: [String] = []
    private(set) var events: [LogEvent] = []

    init(supportsANSIColors: Bool = false) {
        self.supportsANSIColors = supportsANSIColors
    }

    func write(event: LogEvent, rendered: String) {
        lock.lock()
        events.append(event)
        messages.append(rendered)
        lock.unlock()
    }
}

private final class LockedStringBuffer: @unchecked Sendable {
    private let lock = NSLock()
    private(set) var values: [String] = []

    func append(_ value: String) {
        lock.lock()
        values.append(value)
        lock.unlock()
    }
}

private enum DisabledBuildConfiguration: LoggerBuildConfigurationProviding {
    static let isLoggingEnabled = false
}
