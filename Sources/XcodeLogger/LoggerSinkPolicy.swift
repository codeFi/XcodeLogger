//
//  LoggerSinkPolicy.swift
//  XcodeLogger
//
/*
 *  Created by Razvan Tanase on 21/06/26.
 *  Copyright (c) 2026 Codebringers Software SRL. All rights reserved.
 */

public struct LoggerSinkPolicy: Sendable, Equatable {
    public var minimumLevel: LoggerLevel?
    public var enabledCategories: Set<LoggerCategory>?
    public var categoryLevels: [LoggerCategory: LoggerLevel]
    public var allowedLevelsByFile: [String: Set<LoggerLevel>]
    public var globalAllowedLevels: Set<LoggerLevel>?
    public var categoryRules: [LoggerCategoryRule]
    public var rateLimitRules: [LoggerRateLimitRule]
    public var samplingRules: [LoggerSamplingRule]

    public init(
        minimumLevel: LoggerLevel? = nil,
        enabledCategories: Set<LoggerCategory>? = nil,
        categoryLevels: [LoggerCategory: LoggerLevel] = [:],
        allowedLevelsByFile: [String: Set<LoggerLevel>] = [:],
        globalAllowedLevels: Set<LoggerLevel>? = nil,
        categoryRules: [LoggerCategoryRule] = [],
        rateLimitRules: [LoggerRateLimitRule] = [],
        samplingRules: [LoggerSamplingRule] = []
    ) {
        self.minimumLevel = minimumLevel
        self.enabledCategories = enabledCategories
        self.categoryLevels = categoryLevels
        self.allowedLevelsByFile = allowedLevelsByFile
        self.globalAllowedLevels = globalAllowedLevels
        self.categoryRules = categoryRules
        self.rateLimitRules = rateLimitRules
        self.samplingRules = samplingRules
    }
}
