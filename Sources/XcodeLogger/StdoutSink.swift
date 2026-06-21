//
//  StdoutSink.swift
//  XcodeLogger
//
/*
 *  Created by Razvan Tanase on 15/06/26.
 *  Copyright (c) 2026 Codebringers Software SRL. All rights reserved.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 *
 */// Project's Source: https://github.com/codeFi/XcodeLogger

import Foundation

public final class StdoutSink: LoggerSink {
    public let supportsANSIColors: Bool

    private let writer: @Sendable (String) -> Void

    public init(
        supportsANSIColors: Bool? = nil,
        writer: (@Sendable (String) -> Void)? = nil
    ) {
        self.supportsANSIColors = supportsANSIColors ?? LoggerConfiguration.isANSISupportedByEnvironment()
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
