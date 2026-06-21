//
//  DemoRunner.swift
//  XcodeLogger
//
/*
 *  Created by Razvan Tanase on 15/06/26.
 *  Copyright (c) 2026 Codebringers Software SRL. All rights reserved.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 *
 */// Project's Source: https://github.com/codeFi/XcodeLogger

import Foundation
import XcodeLogger

public struct DemoRunReport: Sendable {
    public let captureFilePath: String
    public let capturedLines: [String]
    public let osLogEnabled: Bool
    public let subsystem: String
}

public struct DemoScenarioStep: Equatable, Sendable {
    public enum Action: String, Equatable, Sendable {
        case levels
        case categories
        case sinks
        case theme
        case filters
        case formatting
        case metadata
        case compatibility
        case ansiOn
        case ansiOff
    }

    public let title: String
    public let explanation: String
    public let action: Action
    public let options: DemoOptions

    public init(title: String, explanation: String, action: Action, options: DemoOptions) {
        self.title = title
        self.explanation = explanation
        self.action = action
        self.options = options
    }
}

public enum DemoScenarioPlanner {
    public static func steps(for scenario: DemoScenarioID, baseOptions: DemoOptions) -> [DemoScenarioStep] {
        switch scenario {
        case .levels:
            return [
                .init(
                    title: "Levels",
                    explanation: "This scenario emits every supported level, including the `.simpleNoHeader` variant.",
                    action: .levels,
                    options: baseOptions
                )
            ]
        case .categories:
            return [
                .init(
                    title: "Categories",
                    explanation: "This scenario walks the built-in categories and a custom `payments` category.",
                    action: .categories,
                    options: baseOptions
                )
            ]
        case .sinks:
            return [
                .init(
                    title: "DebugConsoleSink Only",
                    explanation: "Only the formatted debug sink is active here, so everything is captured locally.",
                    action: .sinks,
                    options: with(baseOptions, sinkMode: .debugOnly)
                ),
                .init(
                    title: "StdoutSink Only",
                    explanation: "Only the stdout sink is active here, so the fully rendered lines go straight to standard output.",
                    action: .sinks,
                    options: with(baseOptions, sinkMode: .stdoutOnly)
                ),
                .init(
                    title: "OSLogSink Only",
                    explanation: "Only Unified Logging is active here. The capture file will stay quiet because no debug sink is attached.",
                    action: .sinks,
                    options: with(baseOptions, sinkMode: .osLogOnly)
                ),
                .init(
                    title: "All Sinks",
                    explanation: "All sinks are active here so you can compare system logging, stdout, and formatted debug output together.",
                    action: .sinks,
                    options: with(baseOptions, sinkMode: .all)
                )
            ]
        case .themes:
            return [
                .init(
                    title: "Default Light",
                    explanation: "The same events are rendered with the `defaultLight` theme.",
                    action: .theme,
                    options: with(baseOptions, themeChoice: .defaultLight)
                ),
                .init(
                    title: "Default Dark",
                    explanation: "The same events are rendered with the `defaultDark` theme.",
                    action: .theme,
                    options: with(baseOptions, themeChoice: .defaultDark)
                ),
                .init(
                    title: "Dracula",
                    explanation: "The same events are rendered with the `dracula` theme.",
                    action: .theme,
                    options: with(baseOptions, themeChoice: .dracula)
                )
            ]
        case .filters:
            return [
                .init(
                    title: "Global Minimum Level",
                    explanation: "A global minimum level of `.warning` keeps low-priority events out of every category.",
                    action: .filters,
                    options: with(baseOptions, minimumLevel: .warning)
                ),
                .init(
                    title: "Per-Category Minimum",
                    explanation: "The global level stays at `.error`, but `payments` is lowered to `.information` to show category-specific thresholds.",
                    action: .filters,
                    options: DemoOptions(
                        minimumLevel: .error,
                        enabledCategories: baseOptions.enabledCategories,
                        sinkMode: baseOptions.sinkMode,
                        themeChoice: baseOptions.themeChoice,
                        ansiEnabled: baseOptions.ansiEnabled
                    )
                ),
                .init(
                    title: "Enabled Categories",
                    explanation: "Only `debug` and `payments` are enabled in this pass.",
                    action: .filters,
                    options: with(baseOptions, enabledCategories: [.debug, DemoScenarioCatalog.payments])
                ),
                .init(
                    title: "Allowed Levels Override",
                    explanation: "An explicit global allowed-level set overrides the normal threshold calculation.",
                    action: .filters,
                    options: baseOptions
                ),
                .init(
                    title: "File-Based Allowed Levels",
                    explanation: "A synthetic source path is used here so file-based overrides can be exercised deterministically.",
                    action: .filters,
                    options: baseOptions
                )
            ]
        case .formatting:
            return [
                .init(
                    title: "Default Formatting",
                    explanation: "This is the package default header layout and timestamp format.",
                    action: .formatting,
                    options: baseOptions
                ),
                .init(
                    title: "Custom Header Tokens",
                    explanation: "This pass replaces the default header with category, metadata, and source-line tokens.",
                    action: .formatting,
                    options: baseOptions
                ),
                .init(
                    title: "Custom Timestamp",
                    explanation: "This pass uses a different timestamp format so date precision is visible.",
                    action: .formatting,
                    options: baseOptions
                ),
                .init(
                    title: "Header and Message Newlines",
                    explanation: "This pass inserts a line break after the header and another after the message body.",
                    action: .formatting,
                    options: baseOptions
                )
            ]
        case .metadata:
            return [
                .init(
                    title: "Metadata",
                    explanation: "This scenario emits metadata and calls out that `OSLogSink` records a structured message rather than the debug sink’s themed string.",
                    action: .metadata,
                    options: baseOptions
                )
            ]
        case .compatibility:
            return [
                .init(
                    title: "Compatibility Facade",
                    explanation: "This scenario routes legacy `XLog` style calls through `XcodeLogger.shared` and shows that the mapping is category-based, not scheme-based.",
                    action: .compatibility,
                    options: baseOptions
                )
            ]
        case .ansiOn:
            return [
                .init(
                    title: "ANSI Enabled",
                    explanation: "This forces ANSI-capable debug output. Xcode may still ignore or restyle ANSI sequences independently.",
                    action: .ansiOn,
                    options: with(baseOptions, ansiEnabled: true)
                )
            ]
        case .ansiOff:
            return [
                .init(
                    title: "ANSI Disabled",
                    explanation: "This forces plain-text debug output with no ANSI escape sequences.",
                    action: .ansiOff,
                    options: with(baseOptions, ansiEnabled: false)
                )
            ]
        case .runAll:
            return DemoScenarioID.allCases
                .filter { $0 != .runAll }
                .flatMap { steps(for: $0, baseOptions: baseOptions) }
        }
    }

    private static func with(
        _ options: DemoOptions,
        minimumLevel: LoggerLevel? = nil,
        enabledCategories: Set<LoggerCategory>?? = nil,
        sinkMode: DemoSinkMode? = nil,
        themeChoice: DemoThemeChoice? = nil,
        ansiEnabled: Bool? = nil
    ) -> DemoOptions {
        DemoOptions(
            minimumLevel: minimumLevel ?? options.minimumLevel,
            enabledCategories: enabledCategories ?? options.enabledCategories,
            sinkMode: sinkMode ?? options.sinkMode,
            themeChoice: themeChoice ?? options.themeChoice,
            ansiEnabled: ansiEnabled ?? options.ansiEnabled
        )
    }
}

public final class DemoRunner: @unchecked Sendable {
    public let subsystem: String

    public init(subsystem: String) {
        self.subsystem = subsystem
    }

    @discardableResult
    public func runScenario(
        _ scenario: DemoScenarioID,
        options: DemoOptions = DemoOptions(),
        output: ((String) -> Void)? = nil
    ) -> DemoRunReport {
        let capture = DemoCapture()
        let steps = DemoScenarioPlanner.steps(for: scenario, baseOptions: options)

        for step in steps {
            output?(step.explanation)
            let configuration = makeConfiguration(for: step.options, capture: capture)
            emit(step: step, configuration: configuration, capture: capture)
        }

        return DemoRunReport(
            captureFilePath: capture.fileURL.path,
            capturedLines: capture.lines,
            osLogEnabled: steps.contains(where: { $0.options.sinkMode == .osLogOnly || $0.options.sinkMode == .all }),
            subsystem: subsystem
        )
    }
}

extension DemoRunner {
    private func makeConfiguration(for options: DemoOptions, capture: DemoCapture) -> LoggerConfiguration {
        let debugSink = DebugConsoleSink(supportsANSIColors: options.ansiEnabled) { line in
            capture.append(line)
        }
        let stdoutSink = StdoutSink(supportsANSIColors: options.ansiEnabled ? nil : false)

        let sinks: [LoggerSink]
        switch options.sinkMode {
        case .debugOnly:
            sinks = [debugSink]
        case .stdoutOnly:
            sinks = [stdoutSink]
        case .osLogOnly:
            sinks = [OSLogSink(subsystem: subsystem)]
        case .all:
            sinks = [OSLogSink(subsystem: subsystem), debugSink, stdoutSink]
        }

        return LoggerConfiguration(
            subsystem: subsystem,
            enabledCategories: options.enabledCategories,
            minimumLevel: options.minimumLevel,
            theme: options.themeChoice.theme,
            sinks: sinks
        )
    }

    private func emit(step: DemoScenarioStep, configuration: LoggerConfiguration, capture: DemoCapture) {
        capture.append("")
        capture.append("### \(step.title)")

        switch step.action {
        case .levels:
            emitLevels(using: configuration)
        case .categories:
            emitCategories(using: configuration)
        case .sinks:
            emitSinkComparison(using: configuration)
        case .theme:
            emitTheme(using: configuration)
        case .filters:
            emitFilters(step: step, using: configuration)
        case .formatting:
            emitFormatting(step: step, using: configuration)
        case .metadata:
            emitMetadata(using: configuration)
        case .compatibility:
            emitCompatibility(using: configuration)
        case .ansiOn, .ansiOff:
            emitANSI(using: configuration, enabled: step.action == .ansiOn)
        }
    }

    private func emitLevels(using configuration: LoggerConfiguration) {
        let logger = Logger(configuration: configuration)
        for level in LoggerLevel.allCases {
            logger.log(
                level: level,
                category: .default,
                message: "Rendered `\(displayName(for: level))` output",
                metadata: ["scenario": "levels"],
                source: DemoScenarioCatalog.syntheticSource
            )
        }
    }

    private func emitCategories(using configuration: LoggerConfiguration) {
        let logger = Logger(configuration: configuration)
        let messages: [(LoggerCategory, String)] = [
            (.default, "Default category event"),
            (.debug, "Debug category event"),
            (.development, "Development category event"),
            (.debugDevelopment, "Debug-development category event"),
            (.online, "Online category event"),
            (DemoScenarioCatalog.payments, "Custom payments category event")
        ]

        for (category, message) in messages {
            logger.log(level: .information, category: category, message: message, metadata: ["category": category.rawValue], source: DemoScenarioCatalog.syntheticSource)
        }
    }

    private func emitSinkComparison(using configuration: LoggerConfiguration) {
        let logger = Logger(configuration: configuration)
        logger.log(level: .important, category: .debug, message: "Sink combination: \(describe(sinks: configuration.sinks))", metadata: ["sinkMode": describe(sinks: configuration.sinks)], source: DemoScenarioCatalog.syntheticSource)
    }

    private func emitTheme(using configuration: LoggerConfiguration) {
        let logger = Logger(configuration: configuration)
        logger.log(level: .warning, category: .online, message: "Theme palette preview", metadata: ["theme": configuration.theme.name], source: DemoScenarioCatalog.syntheticSource)
        logger.log(level: .error, category: DemoScenarioCatalog.payments, message: "Theme contrast check", metadata: ["theme": configuration.theme.name], source: DemoScenarioCatalog.syntheticSource)
    }

    private func emitFilters(step: DemoScenarioStep, using configuration: LoggerConfiguration) {
        var configuration = configuration
        let logger: Logger

        switch step.title {
        case "Per-Category Minimum":
            configuration.categoryLevels = [DemoScenarioCatalog.payments: .information]
            logger = Logger(configuration: configuration)
            logger.log(level: .warning, category: .default, message: "Hidden by the global `.error` threshold", source: DemoScenarioCatalog.syntheticSource)
            logger.log(level: .information, category: DemoScenarioCatalog.payments, message: "Visible because `payments` is lowered to `.information`", source: DemoScenarioCatalog.syntheticSource)
        case "Enabled Categories":
            logger = Logger(configuration: configuration)
            logger.log(level: .information, category: .online, message: "Hidden because `online` is disabled", source: DemoScenarioCatalog.syntheticSource)
            logger.log(level: .information, category: DemoScenarioCatalog.payments, message: "Visible because `payments` remains enabled", source: DemoScenarioCatalog.syntheticSource)
        case "Allowed Levels Override":
            configuration.globalAllowedLevels = [.information]
            logger = Logger(configuration: configuration)
            logger.log(level: .warning, category: .debug, message: "Hidden because only `.information` is allowed globally", source: DemoScenarioCatalog.syntheticSource)
            logger.log(level: .information, category: .debug, message: "Visible due to explicit global allowed-level override", source: DemoScenarioCatalog.syntheticSource)
        case "File-Based Allowed Levels":
            configuration.allowedLevelsByFile = ["DEMOSYNTHETIC.SWIFT": [.simple, .error]]
            logger = Logger(configuration: configuration)
            logger.log(level: .warning, category: .debug, message: "Hidden because the file override excludes `.warning`", source: DemoScenarioCatalog.syntheticSource)
            logger.log(level: .error, category: .debug, message: "Visible because the file override allows `.error`", source: DemoScenarioCatalog.syntheticSource)
        default:
            logger = Logger(configuration: configuration)
            logger.log(level: .information, category: .default, message: "Hidden by the `.warning` minimum", source: DemoScenarioCatalog.syntheticSource)
            logger.log(level: .warning, category: .default, message: "Visible at the configured global minimum", source: DemoScenarioCatalog.syntheticSource)
        }
    }

    private func emitFormatting(step: DemoScenarioStep, using configuration: LoggerConfiguration) {
        var configuration = configuration
        switch step.title {
        case "Custom Header Tokens":
            configuration.formatting = LoggerFormatting(
                timestampFormat: configuration.formatting.timestampFormat,
                headerTokens: [.literal("<"), .category, .literal("> "), .metadata, .literal(" @"), .line],
                lineSeparatorAfterHeader: " ",
                lineSeparatorAfterMessage: ""
            )
        case "Custom Timestamp":
            configuration.formatting = LoggerFormatting(
                timestampFormat: "yyyy-MM-dd HH:mm:ss",
                headerTokens: [.literal("["), .timestamp, .literal("] "), .label, .literal(" "), .file],
                lineSeparatorAfterHeader: " ",
                lineSeparatorAfterMessage: ""
            )
        case "Header and Message Newlines":
            configuration.formatting = LoggerFormatting(
                timestampFormat: configuration.formatting.timestampFormat,
                headerTokens: [.label, .literal(" "), .file, .literal(":"), .line],
                lineSeparatorAfterHeader: "\n",
                lineSeparatorAfterMessage: "\n"
            )
        default:
            break
        }

        let logger = Logger(configuration: configuration)
        logger.log(
            level: .important,
            category: DemoScenarioCatalog.payments,
            message: "Formatting preview body",
            metadata: ["invoice": "inv-42", "state": "settled"],
            source: DemoScenarioCatalog.syntheticSource
        )
    }

    private func emitMetadata(using configuration: LoggerConfiguration) {
        let logger = Logger(configuration: configuration)
        logger.log(
            level: .information,
            category: .online,
            message: "Metadata is attached to this event",
            metadata: [
                "requestID": "req-1001",
                "region": "eu-central",
                "effect": "OSLogSink uses the structured message representation"
            ],
            source: DemoScenarioCatalog.syntheticSource
        )
    }

    private func emitCompatibility(using configuration: LoggerConfiguration) {
        Logger.shared.updateConfiguration { current in
            current = configuration
        }

        let entries: [(String, XLOGGER_TYPE)] = [
            ("XLog", .NSLogReplacement),
            ("DLog", .debug),
            ("DVLog", .development),
            ("DDLog", .debugDevelopment),
            ("OLog", .onlineServices)
        ]

        for (macro, type) in entries {
            XcodeLogger.shared.emitCompatibilityLog(
                type: type,
                level: .information,
                file: DemoScenarioCatalog.syntheticSource.file,
                function: "\(macro)()",
                line: DemoScenarioCatalog.syntheticSource.line,
                message: "\(macro) routes to `\(legacyCategoryName(for: type))`"
            )
        }
    }

    private func emitANSI(using configuration: LoggerConfiguration, enabled: Bool) {
        let logger = Logger(configuration: configuration)
        logger.log(
            level: .warning,
            category: .debug,
            message: enabled ? "ANSI escape sequences are enabled for the debug sink." : "ANSI escape sequences are disabled, so this stays plain text.",
            metadata: ["ansi": enabled ? "enabled" : "disabled"],
            source: DemoScenarioCatalog.syntheticSource
        )
    }

    private func describe(sinks: [LoggerSink]) -> String {
        let names = sinks.map { sink in
            if sink is OSLogSink {
                return "OSLogSink"
            }
            if sink is DebugConsoleSink {
                return "DebugConsoleSink"
            }
            if sink is StdoutSink {
                return "StdoutSink"
            }
            return String(describing: type(of: sink))
        }
        return names.joined(separator: " + ")
    }

    private func legacyCategoryName(for type: XLOGGER_TYPE) -> String {
        switch type {
        case .NSLogReplacement:
            return LoggerCategory.default.rawValue
        case .debug:
            return LoggerCategory.debug.rawValue
        case .development:
            return LoggerCategory.development.rawValue
        case .debugDevelopment:
            return LoggerCategory.debugDevelopment.rawValue
        case .onlineServices:
            return LoggerCategory.online.rawValue
        case .all:
            return LoggerCategory.default.rawValue
        }
    }

    private func displayName(for level: LoggerLevel) -> String {
        switch level {
        case .simple:
            return ".simple"
        case .simpleNoHeader:
            return ".simpleNoHeader"
        case .information:
            return ".information"
        case .important:
            return ".important"
        case .warning:
            return ".warning"
        case .error:
            return ".error"
        }
    }
}
