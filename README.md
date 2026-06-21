# XcodeLogger

Modern Apple-platform logging with:

- rich Xcode and Console.app output through `OSLogSink`
- fully rendered terminal/stdout output through `StdoutSink`
- customizable formatted debug output through `DebugConsoleSink`
- a compatibility facade for the legacy `XLog` / `DLog` family

`XcodeLogger` is now a Swift-first library distributed primarily through Swift Package Manager. The SwiftPM package serves only the source files under `Sources/XcodeLogger`. Demo apps and demo support code remain in `Examples`, but they are not package products.

## Highlights

- Unified logging via `os.Logger`
- rich header formatting with file, line, function, timestamp, and metadata
- category-aware and file-aware filtering
- theme support for human-readable debug output
- ANSI color support in real terminals
- Xcode-aware stdout behavior: plain text in Xcode, ANSI in real terminals
- compatibility routing for `XLog`, `DLog`, `DVLog`, `DDLog`, and `OLog`

## Supported Platforms

- iOS 17+
- macOS 14+
- tvOS 17+
- watchOS 10+
- visionOS 1+

## Installation

### Swift Package Manager

Add the package from GitHub and depend on the `XcodeLogger` product.

```swift
dependencies: [
    .package(url: "https://github.com/codeFi/XcodeLogger.git", from: "2.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "XcodeLogger", package: "XcodeLogger")
        ]
    )
]
```

## Quick Start

```swift
import XcodeLogger

let logger = Logger(configuration: LoggerConfiguration(
    subsystem: "com.example.app",
    minimumLevel: .information,
    theme: .defaultDark
))

logger.log(
    level: .warning,
    category: .online,
    message: "Remote service degraded",
    metadata: ["region": "eu-central"]
)
```

## Core Types

- `Logger`
- `LoggerConfiguration`
- `LoggerLevel`
- `LoggerCategory`
- `LoggerFormatting`
- `LoggerTheme`
- `LogEvent`
- `LogSource`
- `LoggerSink`
- `OSLogSink`
- `DebugConsoleSink`
- `StdoutSink`
- `XcodeLogger`

## Levels

- `.simple`
- `.simpleNoHeader`
- `.information`
- `.important`
- `.warning`
- `.error`

## Categories

Built-in categories:

- `default`
- `debug`
- `development`
- `debug-development`
- `online`

Custom categories:

```swift
let payments = LoggerCategory(rawValue: "payments")
```

## Basic Setup Patterns

### 1. Xcode / Console.app focused logging

Use `OSLogSink` when you want the best Xcode and Console.app experience.

```swift
import XcodeLogger

let logger = Logger(configuration: LoggerConfiguration(
    subsystem: "com.example.app",
    sinks: [
        OSLogSink(subsystem: "com.example.app")
    ]
))
```

### 2. Terminal / CLI focused logging

Use `StdoutSink` when you want the fully rendered line on stdout.

```swift
import XcodeLogger

let logger = Logger(configuration: LoggerConfiguration(
    subsystem: "com.example.cli",
    theme: .dracula,
    sinks: [
        StdoutSink()
    ]
))
```

Behavior:

- in Terminal / iTerm, ANSI is enabled by default when supported
- under Xcode, stdout defaults to plain text to avoid raw escape fragments

### 3. Custom debug panel or in-app capture

Use `DebugConsoleSink` when you want to intercept the fully rendered line yourself.

```swift
import XcodeLogger

final class LogBuffer: @unchecked Sendable {
    private let lock = NSLock()
    private(set) var lines: [String] = []

    func append(_ line: String) {
        lock.lock()
        lines.append(line)
        lock.unlock()
    }
}

let buffer = LogBuffer()

let logger = Logger(configuration: LoggerConfiguration(
    subsystem: "com.example.debug-panel",
    theme: .dracula,
    sinks: [
        DebugConsoleSink(supportsANSIColors: false) { line in
            buffer.append(line)
        }
    ]
))
```

### 4. Combined production + debug sinks

```swift
import XcodeLogger

let subsystem = "com.example.app"

let logger = Logger(configuration: LoggerConfiguration(
    subsystem: subsystem,
    minimumLevel: .information,
    theme: .defaultDark,
    sinks: [
        OSLogSink(subsystem: subsystem),
        StdoutSink(),
        DebugConsoleSink(supportsANSIColors: false)
    ]
))
```

## Configuration Guide

`LoggerConfiguration` controls:

- global minimum level
- per-category minimum levels
- enabled category filtering
- global allowed-level overrides
- file-based allowed-level overrides
- theme selection
- header tokens
- timestamp format
- line separators
- sink selection

### Example: category thresholds + formatting

```swift
import XcodeLogger

let configuration = LoggerConfiguration(
    subsystem: "com.example.app",
    enabledCategories: [.debug, .online],
    minimumLevel: .information,
    categoryLevels: [
        .debug: .simple,
        .online: .warning
    ],
    theme: .defaultDark,
    formatting: LoggerFormatting(
        timestampFormat: "HH:mm:ss.SSS",
        headerTokens: [
            .literal("["),
            .label,
            .literal("] "),
            .timestamp,
            .literal(" "),
            .file,
            .literal(":"),
            .line,
            .literal(" "),
            .function
        ],
        lineSeparatorAfterHeader: " ",
        lineSeparatorAfterMessage: "\n"
    )
)

let logger = Logger(configuration: configuration)
```

### Example: file-based allowed-level override

```swift
import XcodeLogger

var configuration = LoggerConfiguration(subsystem: "com.example.app")
configuration.allowedLevelsByFile["PAYMENTSSERVICE.SWIFT"] = [.warning, .error]

let logger = Logger(configuration: configuration)
```

### Example: metadata-rich events

```swift
import XcodeLogger

let logger = Logger(configuration: LoggerConfiguration(subsystem: "com.example.app"))

logger.log(
    level: .information,
    category: .debug,
    message: "Request completed",
    metadata: [
        "requestID": "req-1001",
        "region": "eu-central",
        "status": "200"
    ]
)
```

## Environment Overrides

`LoggerConfiguration.applyingEnvironment(_:)` supports:

- `XCODELOGGER_LEVEL`
- `XCODELOGGER_CATEGORIES`
- `XCODELOGGER_ANSI`

Example:

```swift
import XcodeLogger

let configuration = LoggerConfiguration(subsystem: "com.example.app")
    .applyingEnvironment(ProcessInfo.processInfo.environment)

let logger = Logger(configuration: configuration)
```

## Sink Behavior

### `OSLogSink`

- writes a rich plain-text line into Apple’s Unified Logging system
- best for Xcode and Console.app
- does not rely on ANSI escapes

### `StdoutSink`

- writes the fully rendered line to standard output
- uses ANSI in real terminals when supported
- defaults to plain text under Xcode
- respects `XCODELOGGER_ANSI`

### `DebugConsoleSink`

- writes the fully rendered line through a closure
- ideal for custom panels, buffers, file capture, or test harnesses

## Compatibility Layer

The compatibility facade is category-based, not scheme-based.

Mappings:

- `XLog` -> `default`
- `DLog` -> `debug`
- `DVLog` -> `development`
- `DDLog` -> `debug-development`
- `OLog` -> `online`

The Objective-C macro shim lives in [Compatibility/XcodeLogger.h](Compatibility/XcodeLogger.h).

### Compatibility example

```swift
import XcodeLogger

XcodeLogger.shared.emitCompatibilityLog(
    type: .debug,
    level: .important,
    file: #fileID,
    function: #function,
    line: #line,
    message: "Legacy compatibility remains category-based"
)
```

## Demos

The repo contains demos in `Examples`, but they are not part of the SwiftPM package manifest.

Available demo surfaces:

- macOS app: `Examples/XcodeLoggerMacDemo.xcodeproj`
- iOS app: `Examples/XcodeLoggeriOSDemo.xcodeproj`
- terminal demo sources: `Examples/XcodeLoggerTerminalDemo`
- shared demo support code: `Examples/DemoSupport`

The demos cover:

- levels
- categories
- sink combinations
- themes
- filters
- formatting
- metadata
- compatibility routing
- ANSI on / off behavior

### Verified demo builds

macOS:

```bash
xcodebuild -project Examples/XcodeLoggerMacDemo.xcodeproj \
  -scheme XcodeLoggerMacDemo \
  -configuration Debug \
  -sdk macosx \
  -derivedDataPath /tmp/XcodeLoggerMacDD \
  -clonedSourcePackagesDirPath /tmp/XcodeLoggerMacPackages \
  build
```

iOS:

```bash
xcodebuild -project Examples/XcodeLoggeriOSDemo.xcodeproj \
  -scheme XcodeLoggeriOSDemo \
  -configuration Debug \
  -sdk iphonesimulator \
  -derivedDataPath /tmp/XcodeLoggeriOSDD \
  -clonedSourcePackagesDirPath /tmp/XcodeLoggeriOSPackages \
  build
```

## Verification

Library tests:

```bash
swift test
```

This repository has been verified with:

- `swift test`
- macOS demo build via `xcodebuild`
- iOS demo build via `xcodebuild`
