//
//  LoggerMetadataRedactionRule.swift
//  XcodeLogger
//
/*
 *  Created by Razvan Tanase on 21/06/26.
 *  Copyright (c) 2026 Codebringers Software SRL. All rights reserved.
 */

public struct LoggerMetadataRedactionRule: Sendable, Equatable {
    public let key: String
    public let replacement: String

    public init(key: String, replacement: String = "[REDACTED]") {
        self.key = key
        self.replacement = replacement
    }
}
