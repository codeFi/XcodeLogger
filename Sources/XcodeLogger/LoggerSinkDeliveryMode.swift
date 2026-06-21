//
//  LoggerSinkDeliveryMode.swift
//  XcodeLogger
//
/*
 *  Created by Razvan Tanase on 21/06/26.
 *  Copyright (c) 2026 Codebringers Software SRL. All rights reserved.
 */

public enum LoggerSinkDeliveryMode: Sendable, Equatable {
    case synchronous
    case asynchronous(batchSize: Int = 1)

    var normalizedBatchSize: Int {
        switch self {
        case .synchronous:
            return 1
        case let .asynchronous(batchSize):
            return max(1, batchSize)
        }
    }
}
