//
//  LoggerRandomNumberGenerator.swift
//  XcodeLogger
//
/*
 *  Created by Razvan Tanase on 21/06/26.
 *  Copyright (c) 2026 Codebringers Software SRL. All rights reserved.
 */

public protocol LoggerRandomNumberGenerator: Sendable {
    func nextUnitInterval() -> Double
}

public struct SystemLoggerRandomNumberGenerator: LoggerRandomNumberGenerator {
    public init() {}

    public func nextUnitInterval() -> Double {
        Double.random(in: 0...1)
    }
}
