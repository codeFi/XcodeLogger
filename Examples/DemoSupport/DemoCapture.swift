//
//  DemoCapture.swift
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

public final class DemoCapture: @unchecked Sendable {
    private let lock = NSLock()
    private let handle: FileHandle

    public let fileURL: URL
    public private(set) var lines: [String] = []

    public init(fileManager: FileManager = .default) {
        let directory = fileManager.temporaryDirectory
        let fileName = "xcodelogger-demo-\(UUID().uuidString).log"
        let fileURL = directory.appendingPathComponent(fileName)
        fileManager.createFile(atPath: fileURL.path, contents: nil)

        guard let handle = try? FileHandle(forWritingTo: fileURL) else {
            fatalError("Unable to create capture file at \(fileURL.path)")
        }

        self.fileURL = fileURL
        self.handle = handle
    }

    deinit {
        try? handle.close()
    }

    public func append(_ line: String) {
        let payload = line + "\n"
        lock.lock()
        lines.append(line)
        if let data = payload.data(using: .utf8) {
            let _ = try? handle.seekToEnd()
            try? handle.write(contentsOf: data)
        }
        lock.unlock()
    }
}
