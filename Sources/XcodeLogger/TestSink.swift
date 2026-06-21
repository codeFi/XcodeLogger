//
//  TestSink.swift
//  XcodeLogger
//
/*
 *  Created by Razvan Tanase on 21/06/26.
 *  Copyright (c) 2026 Codebringers Software SRL. All rights reserved.
 */

import Foundation

public final class TestSink: LoggerSink, LoggerConfigurableSink, @unchecked Sendable {
    public var supportsANSIColors: Bool
    public var deliveryMode: LoggerSinkDeliveryMode
    public var policy: LoggerSinkPolicy

    private let lock = NSLock()
    private(set) public var renderedMessages: [String] = []
    private(set) public var events: [LogEvent] = []

    public init(
        supportsANSIColors: Bool = false,
        deliveryMode: LoggerSinkDeliveryMode = .synchronous,
        policy: LoggerSinkPolicy = LoggerSinkPolicy()
    ) {
        self.supportsANSIColors = supportsANSIColors
        self.deliveryMode = deliveryMode
        self.policy = policy
    }

    public func write(event: LogEvent, rendered: String) {
        lock.lock()
        events.append(event)
        renderedMessages.append(rendered)
        lock.unlock()
    }

    public func reset() {
        lock.lock()
        events.removeAll()
        renderedMessages.removeAll()
        lock.unlock()
    }
}
