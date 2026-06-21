# XcodeLogger

[![Version](https://img.shields.io/cocoapods/v/XcodeLogger.svg?style=flat)](http://cocoapods.org/pods/XcodeLogger)
[![License](https://img.shields.io/cocoapods/l/XcodeLogger.svg?style=flat)](https://github.com/codeFi/XcodeLogger/blob/master/LICENSE)
[![Platform](https://img.shields.io/cocoapods/p/XcodeLogger.svg?style=flat)](http://cocoapods.org/pods/XcodeLogger)

XcodeLogger is a Swift package for Apple-platform logging. The current implementation is centered on Unified Logging through `os.Logger`, with an optional ANSI-capable debug sink and a compatibility facade that preserves the old `XLog` / `DLog` family as category-based routing.

The Swift package under `Sources/XcodeLogger` is the primary implementation. The legacy Objective-C sources remain in `XcodeLogger/Core` for compatibility and reference work, but the old scheme-driven sample apps are gone.

## Package

- Library product: `XcodeLogger`
- SwiftPM ships only the library target under `Sources/XcodeLogger`

Supported package platforms:

- iOS 17+
- macOS 14+
- tvOS 17+
- watchOS 10+
- visionOS 1+

## Installation

Add the package and depend on `XcodeLogger`.

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
    theme: .dracula
))

logger.log(
    level: .warning,
    category: .online,
    message: "Remote service degraded",
    metadata: ["region": "eu-central"]
)
```

## Core API

Main types:

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

Built-in categories:

- `default`
- `debug`
- `development`
- `debug-development`
- `online`

Custom categories work the same way:

```swift
let payments = LoggerCategory(rawValue: "payments")
```

Levels:

- `.simple`
- `.simpleNoHeader`
- `.information`
- `.important`
- `.warning`
- `.error`

## Configuration

`LoggerConfiguration` controls:

- global minimum level
- per-category minimum levels
- enabled category filtering
- global allowed-level overrides
- file-based allowed-level overrides
- theme selection
- header and timestamp formatting
- sink selection

Example:

```swift
let configuration = LoggerConfiguration(
    subsystem: "com.example.app",
    enabledCategories: [.debug, .online],
    minimumLevel: .information,
    categoryLevels: [.debug: .simple],
    theme: .defaultDark,
    formatting: LoggerFormatting(
        timestampFormat: "HH:mm:ss.SSS",
        headerTokens: [.literal("["), .category, .literal("] "), .timestamp, .literal(" "), .file, .literal(":"), .line],
        lineSeparatorAfterHeader: " ",
        lineSeparatorAfterMessage: "\n"
    )
)
```

Environment overrides are available through:

- `XCODELOGGER_LEVEL`
- `XCODELOGGER_CATEGORIES`
- `XCODELOGGER_ANSI`

## Sinks And ANSI

`OSLogSink` writes into Apple’s Unified Logging system using a rich plain-text line, so Xcode and Console.app can show header information such as timestamp, file, line, and function without relying on ANSI escapes.

`DebugConsoleSink` writes the fully rendered line through a closure, optionally with ANSI color sequences.

`StdoutSink` writes the fully rendered line to standard output. Its default behavior is environment-aware:

- in real terminals, ANSI is enabled when the environment supports it
- under Xcode, ANSI is disabled by default so raw escape fragments are not printed
- `XCODELOGGER_ANSI=true|false` can still explicitly override that behavior

Practical behavior:

- `OSLogSink`: best for Xcode and Console.app
- `StdoutSink`: best for Terminal / iTerm, but plain text under Xcode by default
- `DebugConsoleSink`: best when you want complete control over where rendered output goes

## Compatibility Layer

The compatibility facade is category-based, not scheme-based.

Mappings:

- `XLog` -> `default`
- `DLog` -> `debug`
- `DVLog` -> `development`
- `DDLog` -> `debug-development`
- `OLog` -> `online`

The Objective-C macro shim lives in [Compatibility/XcodeLogger.h](/Users/razvan/Documents/PROJECTS/XcodeLogger/Compatibility/XcodeLogger.h:1).

## Demo Surfaces

The repo still contains demo surfaces in `Examples`, but they are not part of the SwiftPM package manifest and are not served as package products.

Available demos in the repository:

- macOS app: `Examples/XcodeLoggerMacDemo.xcodeproj`
- iOS app: `Examples/XcodeLoggeriOSDemo.xcodeproj`
- terminal demo sources: `Examples/XcodeLoggerTerminalDemo`
- shared demo support sources: `Examples/DemoSupport`

Each demo exercises:

- levels
- categories
- sinks
- themes
- filters
- formatting
- metadata
- compatibility
- ANSI on / off

Sink coverage in the demos includes:

- `OSLogSink`
- `DebugConsoleSink`
- `StdoutSink`
- combined sink runs

### macOS Demo

Project:

- `Examples/XcodeLoggerMacDemo.xcodeproj`

Verified build command:

```bash
xcodebuild -project Examples/XcodeLoggerMacDemo.xcodeproj \
  -scheme XcodeLoggerMacDemo \
  -configuration Debug \
  -sdk macosx \
  -derivedDataPath /tmp/XcodeLoggerMacDD \
  -clonedSourcePackagesDirPath /tmp/XcodeLoggerMacPackages \
  build
```

The macOS app provides:

- scenario sidebar
- theme / level / category / ANSI / sink controls
- run and run-all actions
- in-app captured debug output panel

### iOS Demo

Project:

- `Examples/XcodeLoggeriOSDemo.xcodeproj`

Verified build command:

```bash
xcodebuild -project Examples/XcodeLoggeriOSDemo.xcodeproj \
  -scheme XcodeLoggeriOSDemo \
  -configuration Debug \
  -sdk iphonesimulator \
  -derivedDataPath /tmp/XcodeLoggeriOSDD \
  -clonedSourcePackagesDirPath /tmp/XcodeLoggeriOSPackages \
  build
```

The iOS app provides:

- scenario selection
- theme / level / category / ANSI / sink controls
- run and run-all actions
- in-app captured debug output view

## Verification

Library tests:

```bash
swift test
```

This repository was verified against:

- `swift test`
- macOS demo build via `xcodebuild`
- iOS demo build via `xcodebuild`
