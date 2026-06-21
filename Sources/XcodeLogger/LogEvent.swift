//
//  LogEvent.swift
//  XcodeLogger
//
/*
 *  Created by Razvan Tanase on 21/06/26.
 *  Copyright (c) 2026 Codebringers Software SRL. All rights reserved.
 */

import Foundation

public struct LogEvent: Sendable, Equatable {
    public let timestamp: Date
    public let subsystem: String
    public let level: LoggerLevel
    public let category: LoggerCategory
    public let message: String
    public let metadata: LoggerMetadata
    public let source: LogSource

    public init(
        timestamp: Date = Date(),
        subsystem: String = "",
        level: LoggerLevel,
        category: LoggerCategory,
        message: String,
        metadata: LoggerMetadata = [:],
        source: LogSource
    ) {
        self.timestamp = timestamp
        self.subsystem = subsystem
        self.level = level
        self.category = category
        self.message = message
        self.metadata = metadata
        self.source = source
    }
}
