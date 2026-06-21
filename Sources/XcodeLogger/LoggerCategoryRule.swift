//
//  LoggerCategoryRule.swift
//  XcodeLogger
//
/*
 *  Created by Razvan Tanase on 21/06/26.
 *  Copyright (c) 2026 Codebringers Software SRL. All rights reserved.
 */

import Foundation

public struct LoggerCategoryRule: Sendable, Equatable {
    public enum MatchMode: Sendable, Equatable {
        case allow
        case deny
    }

    public let pattern: String
    public let mode: MatchMode

    public init(pattern: String, mode: MatchMode) {
        self.pattern = pattern
        self.mode = mode
    }
}
