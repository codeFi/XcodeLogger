//
//  FileSink.swift
//  XcodeLogger
//
/*
 *  Created by Razvan Tanase on 21/06/26.
 *  Copyright (c) 2026 Codebringers Software SRL. All rights reserved.
 */

import Foundation

public final class FileSink: LoggerSink, LoggerConfigurableSink, @unchecked Sendable {
    public let supportsANSIColors = false
    public var deliveryMode: LoggerSinkDeliveryMode
    public var policy: LoggerSinkPolicy

    public let fileURL: URL
    public let maximumFileSizeInBytes: Int
    public let maximumArchiveCount: Int
    public let append: Bool

    private let fileManager: FileManager
    private let lock = NSLock()
    private var hasPreparedDestination = false

    public init(
        fileURL: URL,
        maximumFileSizeInBytes: Int,
        maximumArchiveCount: Int,
        append: Bool = true,
        deliveryMode: LoggerSinkDeliveryMode = .asynchronous(batchSize: 16),
        policy: LoggerSinkPolicy = LoggerSinkPolicy(),
        fileManager: FileManager = .default
    ) {
        self.fileURL = fileURL
        self.maximumFileSizeInBytes = max(1, maximumFileSizeInBytes)
        self.maximumArchiveCount = max(0, maximumArchiveCount)
        self.append = append
        self.deliveryMode = deliveryMode
        self.policy = policy
        self.fileManager = fileManager
    }

    public func write(event: LogEvent, rendered: String) {
        let payload = rendered.hasSuffix("\n") ? rendered : rendered + "\n"
        guard let data = payload.data(using: .utf8) else {
            return
        }

        lock.lock()
        defer { lock.unlock() }

        prepareDestinationIfNeeded()
        rotateIfNeeded(appendingBytes: data.count)
        if !fileManager.fileExists(atPath: fileURL.path) {
            fileManager.createFile(atPath: fileURL.path, contents: nil)
        }

        guard let handle = try? FileHandle(forWritingTo: fileURL) else {
            return
        }
        defer { try? handle.close() }
        do {
            try handle.seekToEnd()
            try handle.write(contentsOf: data)
        } catch {
            assertionFailure("Failed to write log file: \(error)")
        }
    }
}

extension FileSink {
    private func prepareDestinationIfNeeded() {
        guard !hasPreparedDestination else {
            return
        }
        hasPreparedDestination = true

        let directory = fileURL.deletingLastPathComponent()
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)

        if !append, fileManager.fileExists(atPath: fileURL.path) {
            try? fileManager.removeItem(at: fileURL)
        }
    }

    private func rotateIfNeeded(appendingBytes byteCount: Int) {
        let currentSize = (try? fileManager.attributesOfItem(atPath: fileURL.path)[.size] as? NSNumber)?.intValue ?? 0
        guard currentSize + byteCount > maximumFileSizeInBytes else {
            return
        }

        if maximumArchiveCount > 0 {
            let oldestArchive = archivedURL(index: maximumArchiveCount)
            if fileManager.fileExists(atPath: oldestArchive.path) {
                try? fileManager.removeItem(at: oldestArchive)
            }

            if maximumArchiveCount > 1 {
                for index in stride(from: maximumArchiveCount - 1, through: 1, by: -1) {
                    let source = archivedURL(index: index)
                    let target = archivedURL(index: index + 1)
                    if fileManager.fileExists(atPath: source.path) {
                        try? fileManager.removeItem(at: target)
                        try? fileManager.moveItem(at: source, to: target)
                    }
                }
            }

            if fileManager.fileExists(atPath: fileURL.path) {
                let target = archivedURL(index: 1)
                try? fileManager.removeItem(at: target)
                try? fileManager.moveItem(at: fileURL, to: target)
            }
        } else if fileManager.fileExists(atPath: fileURL.path) {
            try? fileManager.removeItem(at: fileURL)
        }
    }

    private func archivedURL(index: Int) -> URL {
        let directory = fileURL.deletingLastPathComponent()
        let baseName = fileURL.deletingPathExtension().lastPathComponent
        let ext = fileURL.pathExtension
        let fileName = ext.isEmpty ? "\(baseName).\(index)" : "\(baseName).\(index).\(ext)"
        return directory.appendingPathComponent(fileName)
    }
}
