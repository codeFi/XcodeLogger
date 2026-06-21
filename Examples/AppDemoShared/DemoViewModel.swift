//
//  DemoViewModel.swift
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
import SwiftUI
import XcodeLogger

@MainActor
final class DemoViewModel: ObservableObject {
    @Published var selectedScenario: DemoScenarioID = .levels
    @Published var minimumLevel: LoggerLevel = .simple
    @Published var selectedTheme: DemoThemeChoice = .defaultLight
    @Published var sinkMode: DemoSinkMode = .all
    @Published var ansiEnabled = true
    @Published var enabledCategoryNames = Set(DemoScenarioCatalog.categories.map(\.rawValue))
    @Published var output = "Run a scenario to capture formatted debug output here."
    @Published var capturePath = ""

    let runner: DemoRunner

    init(subsystem: String) {
        self.runner = DemoRunner(subsystem: subsystem)
    }

    var scenarioDefinitions: [DemoScenarioDefinition] {
        DemoScenarioCatalog.definitions.filter { $0.id != .runAll }
    }

    var enabledCategoriesSummary: String {
        let selected = DemoScenarioCatalog.categories
            .filter { enabledCategoryNames.contains($0.rawValue) }
            .map(\.rawValue)
        return selected.isEmpty ? "none" : selected.joined(separator: ", ")
    }

    func toggleCategory(_ category: LoggerCategory) {
        if enabledCategoryNames.contains(category.rawValue) {
            enabledCategoryNames.remove(category.rawValue)
        } else {
            enabledCategoryNames.insert(category.rawValue)
        }
    }

    func runSelectedScenario() {
        let report = runner.runScenario(selectedScenario, options: currentOptions)
        output = report.capturedLines.joined(separator: "\n")
        capturePath = report.captureFilePath
    }

    func runAll() {
        let report = runner.runScenario(.runAll, options: currentOptions)
        output = report.capturedLines.joined(separator: "\n")
        capturePath = report.captureFilePath
    }

    private var currentOptions: DemoOptions {
        let selectedCategories = DemoScenarioCatalog.categories.filter { enabledCategoryNames.contains($0.rawValue) }
        let enabled: Set<LoggerCategory>? = selectedCategories.count == DemoScenarioCatalog.categories.count ? nil : Set(selectedCategories)
        return DemoOptions(
            minimumLevel: minimumLevel,
            enabledCategories: enabled,
            sinkMode: sinkMode,
            themeChoice: selectedTheme,
            ansiEnabled: ansiEnabled
        )
    }
}
