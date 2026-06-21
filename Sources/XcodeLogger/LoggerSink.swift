//
//  LoggerSink.swift
//  XcodeLogger
//
/*
 *  Created by Razvan Tanase on 21/06/26.
 *  Copyright (c) 2026 Codebringers Software SRL. All rights reserved.
 */

public protocol LoggerSink: AnyObject {
    var supportsANSIColors: Bool { get }
    func write(event: LogEvent, rendered: String)
}
