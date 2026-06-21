//
//  LoggerMessageRedactor.swift
//  XcodeLogger
//
/*
 *  Created by Razvan Tanase on 21/06/26.
 *  Copyright (c) 2026 Codebringers Software SRL. All rights reserved.
 */

public struct LoggerMessageRedactor: Sendable {
    public let sanitize: @Sendable (String) -> String

    public init(_ sanitize: @escaping @Sendable (String) -> String) {
        self.sanitize = sanitize
    }
}
