//
//  LoggerClock.swift
//  XcodeLogger
//
/*
 *  Created by Razvan Tanase on 21/06/26.
 *  Copyright (c) 2026 Codebringers Software SRL. All rights reserved.
 */

import Foundation

public protocol LoggerClock: Sendable {
    func now() -> Date
}

public struct SystemLoggerClock: LoggerClock {
    public init() {}

    public func now() -> Date {
        Date()
    }
}
