import Foundation
import XCTest
@testable import XcodeLogger

final class XcodeLoggerTests: XCTestCase {
    func testScopedLoggerInheritsCategoryMetadataAndSubsystemOverride() {
        let sink = TestSink()
        let logger = Logger(configuration: LoggerConfiguration(subsystem: "base", sinks: [sink]))
            .category(.networking)
            .scoped(metadata: ["requestID": "1"])
            .scoped(subsystem: "child")

        logger.log(level: .information, message: "hello", metadata: ["requestID": "2", "user": "ana"])

        XCTAssertEqual(sink.events.count, 1)
        XCTAssertEqual(sink.events[0].category, .networking)
        XCTAssertEqual(sink.events[0].subsystem, "child")
        XCTAssertEqual(sink.events[0].metadata["requestID"], "2")
        XCTAssertEqual(sink.events[0].metadata["user"], "ana")
    }

    func testScopedLoggerCanOverrideInheritedCategory() {
        let sink = TestSink()
        let base = Logger(configuration: LoggerConfiguration(subsystem: "base", sinks: [sink])).category(.debug)
        let child = base.scoped(category: .development, metadata: ["scope": "child"])

        child.log(level: .important, message: "value")

        XCTAssertEqual(sink.events.first?.category, .development)
        XCTAssertEqual(sink.events.first?.metadata["scope"], "child")
    }

    func testWhenEnabledProvidesSimpleBuildPolicyBridge() {
        let sink = TestSink()
        let logger = Logger(configuration: LoggerConfiguration(subsystem: "test", sinks: [sink]).whenEnabled(false))

        logger.log(level: .error, message: "ignored")

        XCTAssertTrue(sink.events.isEmpty)
    }

    func testPerSinkMinimumLevelsCanDiffer() {
        let infoSink = TestSink(policy: LoggerSinkPolicy(minimumLevel: .information))
        let errorSink = TestSink(policy: LoggerSinkPolicy(minimumLevel: .error))
        let logger = Logger(configuration: LoggerConfiguration(subsystem: "test", sinks: [infoSink, errorSink]))

        logger.log(level: .warning, category: .debug, message: "warning")
        logger.log(level: .error, category: .debug, message: "error")

        XCTAssertEqual(infoSink.events.map(\.level), [.warning, .error])
        XCTAssertEqual(errorSink.events.map(\.level), [.error])
    }

    func testPerSinkRegexRulesAndFileOverrides() {
        let sink = TestSink(policy: LoggerSinkPolicy(
            minimumLevel: .error,
            allowedLevelsByFile: ["SPECIAL.SWIFT": [.warning]],
            categoryRules: [
                LoggerCategoryRule(pattern: "^debug$", mode: .allow),
                LoggerCategoryRule(pattern: "network", mode: .deny),
                LoggerCategoryRule(pattern: "([", mode: .allow)
            ]
        ))
        let logger = Logger(configuration: LoggerConfiguration(subsystem: "test", sinks: [sink]))

        logger.log(level: .warning, category: .debug, message: "allowed by file", source: LogSource(file: "Special.swift", function: "run()", line: 1))
        logger.log(level: .error, category: .networking, message: "denied", source: LogSource(file: "Special.swift", function: "run()", line: 2))
        logger.log(level: .error, category: .development, message: "blocked by allow list", source: LogSource(file: "Other.swift", function: "run()", line: 3))

        XCTAssertEqual(sink.events.count, 1)
        XCTAssertEqual(sink.events.first?.message, "allowed by file")
    }

    func testRedactionAppliesBeforeRenderingForAllSinks() {
        let sinkA = TestSink()
        let sinkB = TestSink(supportsANSIColors: true)
        let logger = Logger(configuration: LoggerConfiguration(
            subsystem: "test",
            metadataRedactionRules: [LoggerMetadataRedactionRule(key: "token")],
            messageRedactors: [LoggerMessageRedactor { $0.replacingOccurrences(of: "secret", with: "[REDACTED]") }],
            sinks: [sinkA, sinkB]
        ))

        logger.log(level: .warning, category: .debug, message: "secret payload", metadata: ["token": "abc"])

        XCTAssertEqual(sinkA.events.first?.metadata["token"], "[REDACTED]")
        XCTAssertEqual(sinkB.events.first?.metadata["token"], "[REDACTED]")
        XCTAssertFalse(sinkA.renderedMessages[0].contains("secret"))
        XCTAssertFalse(sinkA.renderedMessages[0].contains("abc"))
        XCTAssertFalse(sinkB.renderedMessages[0].contains("secret"))
        XCTAssertFalse(sinkB.renderedMessages[0].contains("abc"))
    }

    func testRateLimitingUsesFixedWindowSuppression() {
        let clock = ManualClock(date: Date(timeIntervalSince1970: 100))
        let sink = TestSink(policy: LoggerSinkPolicy(
            minimumLevel: .simple,
            rateLimitRules: [LoggerRateLimitRule(category: .debug, maximumEvents: 2, window: 60)]
        ))
        let logger = Logger(configuration: LoggerConfiguration(
            subsystem: "test",
            sinks: [sink],
            clock: clock
        ))

        logger.log(level: .information, category: .debug, message: "1")
        logger.log(level: .information, category: .debug, message: "2")
        logger.log(level: .information, category: .debug, message: "3")
        clock.advance(by: 61)
        logger.log(level: .information, category: .debug, message: "4")

        XCTAssertEqual(sink.events.map(\.message), ["1", "2", "4"])
    }

    func testSamplingRulesAreDeterministicWithInjectedRandomness() {
        let sink = TestSink(policy: LoggerSinkPolicy(
            minimumLevel: .simple,
            samplingRules: [LoggerSamplingRule(category: .networking, probability: 0.5)]
        ))
        let logger = Logger(configuration: LoggerConfiguration(
            subsystem: "test",
            sinks: [sink],
            randomNumberGenerator: SequenceRandom(values: [0.1, 0.7, 0.2])
        ))

        logger.log(level: .information, category: .networking, message: "keep-1")
        logger.log(level: .information, category: .networking, message: "drop")
        logger.log(level: .information, category: .networking, message: "keep-2")

        XCTAssertEqual(sink.events.map(\.message), ["keep-1", "keep-2"])
    }

    func testFileSinkWritesAppendsAndRotates() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let fileURL = directory.appendingPathComponent("app.log")
        let sink = FileSink(fileURL: fileURL, maximumFileSizeInBytes: 90, maximumArchiveCount: 2)
        let logger = Logger(configuration: LoggerConfiguration(subsystem: "test", sinks: [sink]))

        for index in 0..<8 {
            logger.log(level: .information, category: .debug, message: "entry-\(index)-payload")
        }

        waitUntil {
            FileManager.default.fileExists(atPath: fileURL.path) &&
            FileManager.default.fileExists(atPath: directory.appendingPathComponent("app.1.log").path)
        }

        let current = try String(contentsOf: fileURL)
        let archive = try String(contentsOf: directory.appendingPathComponent("app.1.log"))
        XCTAssertTrue(current.contains("entry-7-payload"))
        XCTAssertTrue(archive.contains("entry-"))
        XCTAssertFalse(FileManager.default.fileExists(atPath: directory.appendingPathComponent("app.3.log").path))
    }

    func testAsyncSinkDeliveryPreservesEventOrderingAcrossSinks() {
        let sinkA = TestSink(deliveryMode: .asynchronous(batchSize: 8))
        let sinkB = TestSink(deliveryMode: .asynchronous(batchSize: 8))
        let logger = Logger(configuration: LoggerConfiguration(subsystem: "test", sinks: [sinkA, sinkB]))

        for index in 0..<50 {
            logger.log(level: .information, category: .debug, message: "value-\(index)")
        }

        waitUntil {
            sinkA.events.count == 50 && sinkB.events.count == 50
        }

        XCTAssertEqual(sinkA.events.map(\.message), sinkB.events.map(\.message))
        XCTAssertEqual(sinkA.events.first?.message, "value-0")
        XCTAssertEqual(sinkA.events.last?.message, "value-49")
    }

    func testConcurrentLoggingWhileMutatingConfiguration() async {
        let sink = TestSink(deliveryMode: .asynchronous(batchSize: 16))
        let logger = Logger(configuration: LoggerConfiguration(subsystem: "test", sinks: [sink]))

        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                for index in 0..<100 {
                    logger.log(level: .information, category: .debug, message: "log-\(index)", metadata: ["id": "\(index)"])
                }
            }
            group.addTask {
                for index in 0..<50 {
                    logger.updateConfiguration { configuration in
                        configuration.minimumLevel = index.isMultiple(of: 2) ? .simple : .information
                        configuration.theme = index.isMultiple(of: 2) ? .defaultLight : .dracula
                    }
                }
            }
        }

        waitUntil {
            sink.events.count == 100
        }

        XCTAssertEqual(Set(sink.events.compactMap { $0.metadata["id"] }).count, 100)
    }

    func testScopedChildLoggersRemainIsolatedAcrossTaskGroups() async {
        let sink = TestSink(deliveryMode: .asynchronous(batchSize: 16))
        let base = Logger(configuration: LoggerConfiguration(subsystem: "test", sinks: [sink]))

        await withTaskGroup(of: Void.self) { group in
            for value in 0..<40 {
                group.addTask {
                    base.scoped(metadata: ["task": "\(value)"]).category(.debug).log(
                        level: .information,
                        message: "value-\(value)"
                    )
                }
            }
        }

        waitUntil {
            sink.events.count == 40
        }

        XCTAssertEqual(Set(sink.events.compactMap { $0.metadata["task"] }).count, 40)
    }

    func testFormatterStructuredMessageIncludesMetadata() {
        let formatter = LoggerFormatter()
        let event = LogEvent(
            timestamp: Date(timeIntervalSince1970: 1),
            subsystem: "test",
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

    func testDisabledLoggerPerformancePath() {
        let logger = Logger(configuration: LoggerConfiguration(subsystem: "test").whenEnabled(false))

        measure {
            for index in 0..<1_000 {
                logger.log(level: .simple, category: .debug, message: "value-\(index)")
            }
        }
    }

    func testScopedLoggerPerformancePath() {
        let sink = TestSink()
        let logger = Logger(configuration: LoggerConfiguration(subsystem: "test", sinks: [sink]))
        let scoped = logger.category(.debug).scoped(metadata: ["screen": "home"])

        measure {
            sink.reset()
            for index in 0..<500 {
                scoped.log(level: .information, message: "value-\(index)")
            }
        }
    }
}

private final class ManualClock: LoggerClock, @unchecked Sendable {
    private let lock = NSLock()
    private var currentDate: Date

    init(date: Date) {
        self.currentDate = date
    }

    func now() -> Date {
        lock.lock()
        defer { lock.unlock() }
        return currentDate
    }

    func advance(by seconds: TimeInterval) {
        lock.lock()
        currentDate.addTimeInterval(seconds)
        lock.unlock()
    }
}

private final class SequenceRandom: LoggerRandomNumberGenerator, @unchecked Sendable {
    private let lock = NSLock()
    private var values: [Double]
    private var index = 0

    init(values: [Double]) {
        self.values = values
    }

    func nextUnitInterval() -> Double {
        lock.lock()
        defer { lock.unlock() }
        guard !values.isEmpty else {
            return 1
        }
        let value = values[min(index, values.count - 1)]
        index += 1
        return value
    }
}

extension XCTestCase {
    func waitUntil(timeout: TimeInterval = 2, pollInterval: TimeInterval = 0.01, _ condition: @escaping () -> Bool) {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() {
                return
            }
            RunLoop.current.run(until: Date().addingTimeInterval(pollInterval))
        }
        XCTFail("Condition not satisfied before timeout")
    }
}
