//
//  LoggerRateLimitRule.swift
//  XcodeLogger
//
/*
 *  Created by Razvan Tanase on 21/06/26.
 *  Copyright (c) 2026 Codebringers Software SRL. All rights reserved.
 */

import Foundation

public struct LoggerRateLimitRule: Sendable, Equatable {
    public let category: LoggerCategory?
    public let maximumEvents: Int
    public let window: TimeInterval

    public init(category: LoggerCategory? = nil, maximumEvents: Int, window: TimeInterval) {
        self.category = category
        self.maximumEvents = maximumEvents
        self.window = window
    }
}
