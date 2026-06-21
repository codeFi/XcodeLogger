//
//  DemoCLI.swift
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

public enum DemoCLICommand: Equatable, Sendable {
    case interactive
    case list
    case help
    case scenario(DemoScenarioID)
}

public enum DemoCLIArguments {
    public static func parse(_ arguments: [String]) -> DemoCLICommand {
        guard arguments.count > 1 else {
            return .interactive
        }

        var iterator = arguments.dropFirst().makeIterator()
        while let argument = iterator.next() {
            switch argument {
            case "--help", "-h":
                return .help
            case "--list":
                return .list
            case "--scenario", "-s":
                guard let raw = iterator.next(), let scenario = DemoScenarioID(rawValue: raw) else {
                    return .help
                }
                return .scenario(scenario)
            default:
                if let scenario = DemoScenarioID(rawValue: argument) {
                    return .scenario(scenario)
                }
                return .help
            }
        }

        return .interactive
    }

    public static var usage: String {
        """
        Usage:
          swift run XcodeLoggerTerminalDemo
          swift run XcodeLoggerTerminalDemo --list
          swift run XcodeLoggerTerminalDemo --scenario levels
          swift run XcodeLoggerTerminalDemo --scenario run-all
        """
    }
}
