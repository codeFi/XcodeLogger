//
//  LoggerSamplingRule.swift
//  XcodeLogger
//
/*
 *  Created by Razvan Tanase on 21/06/26.
 *  Copyright (c) 2026 Codebringers Software SRL. All rights reserved.
 */

public struct LoggerSamplingRule: Sendable, Equatable {
    public let category: LoggerCategory
    public let probability: Double

    public init(category: LoggerCategory, probability: Double) {
        self.category = category
        self.probability = min(max(probability, 0), 1)
    }
}
