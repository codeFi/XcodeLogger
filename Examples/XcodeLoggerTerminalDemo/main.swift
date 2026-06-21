//
//  main.swift
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
import XcodeLoggerDemoSupport

let command = DemoCLIArguments.parse(CommandLine.arguments)
let runner = DemoRunner(subsystem: "com.codefi.XcodeLoggerTerminalDemo")

switch command {
case .help:
    print(DemoCLIArguments.usage)
case .list:
    for definition in DemoScenarioCatalog.definitions {
        print("\(definition.id.rawValue): \(definition.summary)")
    }
case let .scenario(scenario):
    runScenario(scenario)
case .interactive:
    runInteractiveMenu()
}

func runInteractiveMenu() {
    print("XcodeLogger Terminal Demo")
    print("Select a scenario:")
    let scenarios = DemoScenarioCatalog.definitions
    for (index, definition) in scenarios.enumerated() {
        print("\(index + 1). \(definition.title) (\(definition.id.rawValue))")
    }
    print("Enter a number:", terminator: " ")

    guard
        let line = readLine(),
        let index = Int(line),
        scenarios.indices.contains(index - 1)
    else {
        print(DemoCLIArguments.usage)
        return
    }

    runScenario(scenarios[index - 1].id)
}

func runScenario(_ scenario: DemoScenarioID) {
    let definition = DemoScenarioCatalog.definition(for: scenario)
    print(definition.title)
    print(definition.summary)
    let report = runner.runScenario(scenario) { explanation in
        print(explanation)
    }
    print("Captured debug sink: \(report.captureFilePath)")
    if report.osLogEnabled {
        print("OSLog mirror: enabled for subsystem \(report.subsystem)")
    }
    if !report.capturedLines.isEmpty {
        print(report.capturedLines.joined(separator: "\n"))
    }
}
