//
//  LoggerConfigurableSink.swift
//  XcodeLogger
//
/*
 *  Created by Razvan Tanase on 21/06/26.
 *  Copyright (c) 2026 Codebringers Software SRL. All rights reserved.
 */

public protocol LoggerConfigurableSink: LoggerSink {
    var deliveryMode: LoggerSinkDeliveryMode { get }
    var policy: LoggerSinkPolicy { get }
}
