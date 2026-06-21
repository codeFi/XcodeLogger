//
//  DebugConsoleSink.swift
//  XcodeLogger
//
/*
 *  Created by Razvan Tanase on 21/06/26.
 *  Copyright (c) 2026 Codebringers Software SRL. All rights reserved.
 */

public final class DebugConsoleSink: LoggerSink, LoggerConfigurableSink {
    public var supportsANSIColors: Bool
    public var deliveryMode: LoggerSinkDeliveryMode
    public var policy: LoggerSinkPolicy

    private let writer: @Sendable (String) -> Void

    public init(
        supportsANSIColors: Bool = true,
        deliveryMode: LoggerSinkDeliveryMode = .synchronous,
        policy: LoggerSinkPolicy = LoggerSinkPolicy(),
        writer: @escaping @Sendable (String) -> Void = { print($0) }
    ) {
        self.supportsANSIColors = supportsANSIColors
        self.deliveryMode = deliveryMode
        self.policy = policy
        self.writer = writer
    }

    public func write(event: LogEvent, rendered: String) {
        writer(rendered)
    }
}
