//
//  DemoScenarios.swift
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

public enum DemoScenarioID: String, CaseIterable, Sendable {
    case levels
    case categories
    case sinks
    case themes
    case filters
    case formatting
    case metadata
    case compatibility
    case ansiOn = "ansi-on"
    case ansiOff = "ansi-off"
    case runAll = "run-all"
}

public struct DemoScenarioDefinition: Sendable, Equatable {
    public let id: DemoScenarioID
    public let title: String
    public let summary: String

    public init(id: DemoScenarioID, title: String, summary: String) {
        self.id = id
        self.title = title
        self.summary = summary
    }
}

public enum DemoSinkMode: String, CaseIterable, Sendable {
    case debugOnly
    case stdoutOnly
    case osLogOnly
    case all

    public var title: String {
        switch self {
        case .debugOnly:
            return "Debug Console"
        case .stdoutOnly:
            return "Stdout"
        case .osLogOnly:
            return "OSLog"
        case .all:
            return "All Sinks"
        }
    }
}

public enum DemoThemeChoice: String, CaseIterable, Sendable {
    case defaultLight
    case defaultDark
    case dracula

    public var title: String {
        switch self {
        case .defaultLight:
            return "Default Light"
        case .defaultDark:
            return "Default Dark"
        case .dracula:
            return "Dracula"
        }
    }

    public var theme: LoggerTheme {
        switch self {
        case .defaultLight:
            return .defaultLight
        case .defaultDark:
            return .defaultDark
        case .dracula:
            return .dracula
        }
    }
}

public struct DemoOptions: Sendable, Equatable {
    public var minimumLevel: LoggerLevel
    public var enabledCategories: Set<LoggerCategory>?
    public var sinkMode: DemoSinkMode
    public var themeChoice: DemoThemeChoice
    public var ansiEnabled: Bool

    public init(
        minimumLevel: LoggerLevel = .simple,
        enabledCategories: Set<LoggerCategory>? = nil,
        sinkMode: DemoSinkMode = .all,
        themeChoice: DemoThemeChoice = .defaultLight,
        ansiEnabled: Bool = true
    ) {
        self.minimumLevel = minimumLevel
        self.enabledCategories = enabledCategories
        self.sinkMode = sinkMode
        self.themeChoice = themeChoice
        self.ansiEnabled = ansiEnabled
    }
}

public enum DemoScenarioCatalog {
    public static let payments = LoggerCategory(rawValue: "payments")
    public static let syntheticSource = LogSource(file: "/Demo/Sources/Payments/DemoSynthetic.swift", function: "runScenario()", line: 77)

    public static let definitions: [DemoScenarioDefinition] = [
        .init(id: .levels, title: "Levels", summary: "Exercise `.simple` through `.error`, including the no-header variant."),
        .init(id: .categories, title: "Categories", summary: "Show the built-in categories plus a custom `payments` category."),
        .init(id: .sinks, title: "Sinks", summary: "Compare `OSLogSink`, `DebugConsoleSink`, `StdoutSink`, and the combined path."),
        .init(id: .themes, title: "Themes", summary: "Render the same event with `defaultLight`, `defaultDark`, and `dracula`."),
        .init(id: .filters, title: "Filters", summary: "Demonstrate global, per-category, enabled-category, and allowed-level filtering."),
        .init(id: .formatting, title: "Formatting", summary: "Show header tokens, timestamp format changes, and newline behavior."),
        .init(id: .metadata, title: "Metadata", summary: "Emit event metadata and explain the structured `OSLogSink` effect."),
        .init(id: .compatibility, title: "Compatibility", summary: "Route `XLog`/`DLog`/`DVLog`/`DDLog`/`NLog` through the compatibility facade."),
        .init(id: .ansiOn, title: "ANSI On", summary: "Force ANSI-capable debug output for terminals that honor escapes."),
        .init(id: .ansiOff, title: "ANSI Off", summary: "Force plain-text fallback without ANSI escape codes."),
        .init(id: .runAll, title: "Run All", summary: "Run every scenario in sequence.")
    ]

    public static func definition(for id: DemoScenarioID) -> DemoScenarioDefinition {
        definitions.first(where: { $0.id == id }) ?? .init(id: id, title: id.rawValue, summary: "")
    }

    public static func definition(named name: String) -> DemoScenarioDefinition? {
        definitions.first(where: { $0.id.rawValue == name })
    }

    public static let categories: [LoggerCategory] = [
        .default,
        .debug,
        .development,
        .debugDevelopment,
        .networking,
        payments
    ]
}
