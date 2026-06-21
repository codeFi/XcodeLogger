//
//  StdoutSink.swift
//  XcodeLogger
//
/*
 *  Created by Razvan Tanase on 21/06/26.
 *  Copyright (c) 2026 Codebringers Software SRL. All rights reserved.
 */

import Foundation

public final class StdoutSink: LoggerSink, LoggerConfigurableSink {
    public var supportsANSIColors: Bool
    public var deliveryMode: LoggerSinkDeliveryMode
    public var policy: LoggerSinkPolicy

    private let writer: @Sendable (String) -> Void

    public init(
        supportsANSIColors: Bool? = nil,
        deliveryMode: LoggerSinkDeliveryMode = .synchronous,
        policy: LoggerSinkPolicy = LoggerSinkPolicy(),
        writer: (@Sendable (String) -> Void)? = nil
    ) {
        self.supportsANSIColors = supportsANSIColors ?? LoggerConfiguration.isANSISupportedByEnvironment()
        self.deliveryMode = deliveryMode
        self.policy = policy
        self.writer = writer ?? Self.defaultWriter
    }

    public func write(event: LogEvent, rendered: String) {
        let payload = rendered.hasSuffix("\n") ? rendered : rendered + "\n"
        writer(payload)
    }
}

extension StdoutSink {
    static func defaultWriter(_ string: String) {
        guard let data = string.data(using: .utf8) else {
            return
        }
        try? FileHandle.standardOutput.write(contentsOf: data)
    }
}
