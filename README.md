# XcodeLogger

`XcodeLogger 2.1.0` is the Swift-first replacement for the legacy Objective-C Xcode Logger project.

This version keeps the familiar ideas:

- readable developer-focused log output
- compatibility routing for `XLog`, `DLog`, `DVLog`, `DDLog`, and `NLog`
- file-level and global level filtering

It deliberately changes one important architectural point from the legacy project:

- build-configuration behavior is no longer encoded inside `XcodeLogger`
- your app owns that decision in its own source using compile-time conditions such as `#if DEBUG`
- `XcodeLogger` only consumes the result as a safe on/off policy

That is the main migration path away from the old Info.plist scheme-linking model.

## What Changed From The Legacy Project

The legacy implementation combined two concerns:

- legacy log-family calls such as `DLog`, `DVLog`, `DDLog`, `NLog`, and `XLog`
- app-specific decisions about which builds should emit logs

In this implementation those concerns are split:

- legacy call compatibility remains inside `XcodeLogger`
- build/scheme/configuration policy belongs to the consuming app

This implementation replaces that with:

- Swift Package Manager distribution
- structured `Logger` and `LoggerConfiguration` APIs
- sink-based output routing for `OSLog`, stdout, and custom debug capture
- app-owned compile-time build policies

The practical outcome is better:

- the library no longer needs to know your app's `Debug`, `Release`, `Staging`, or custom configuration names
- disabling logs for a build becomes an app decision expressed in app code
- when disabled, `Logger` exits before writing to any sink

## Supported Platforms

- iOS 17+
- macOS 14+
- tvOS 17+
- watchOS 10+
- visionOS 1+

## Installation

Add the package from GitHub and depend on the `XcodeLogger` product.

```swift
dependencies: [
    .package(url: "https://github.com/codeFi/XcodeLogger.git", from: "2.1.0")
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
    category: .networking,
    message: "Remote service degraded",
    metadata: ["region": "eu-central"]
)
```

## Build Configuration Control

If you want no log output for some builds, define that in your app target, not in `XcodeLogger`.

Important distinction:

- `XcodeLogger` still knows how legacy calls map into modern categories
- your app decides whether those categories should emit anything in `Debug`, `Release`, `Staging`, or any custom build

Built-in legacy compatibility mapping:

- `XLog` -> `default`
- `DLog` -> `debug`
- `DVLog` -> `development`
- `DDLog` -> `debug-development`
- `NLog` -> `networking`

Create an app-owned file such as `AppLogBuildConfiguration.swift`:

```swift
import XcodeLogger

enum AppLogBuildConfiguration: LoggerBuildConfigurationProviding {
    static let isLoggingEnabled: Bool = {
        #if DEBUG
        true
        #elseif STAGING
        true
        #else
        false
        #endif
    }()
}
```

Then apply it when constructing the logger configuration:

```swift
import XcodeLogger

let configuration = LoggerConfiguration(
    subsystem: "com.example.app",
    minimumLevel: .information,
    sinks: [
        OSLogSink(subsystem: "com.example.app"),
        DebugConsoleSink()
    ]
).applyingBuildConfiguration(AppLogBuildConfiguration.self)

let logger = Logger(configuration: configuration)
```

Why this is the recommended approach:

- the compile-time conditions stay in the app that owns the build settings
- `XcodeLogger` stays generic and reusable
- disabling logs is explicit and easy to audit
- the logger performs a hard early exit when `isEnabled == false`

If you do not need a provider type, you can pass the resolved value directly:

```swift
let configuration = LoggerConfiguration(
    subsystem: "com.example.app",
    isEnabled: false
)
```

## Core Types

- `Logger`
- `LoggerConfiguration`
- `LoggerBuildConfigurationProviding`
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

## Output Sinks

### `OSLogSink`

Use this when you want the best integration with Xcode and Console.app.

```swift
let logger = Logger(configuration: LoggerConfiguration(
    subsystem: "com.example.app",
    sinks: [
        OSLogSink(subsystem: "com.example.app")
    ]
))
```

### `StdoutSink`

Use this for terminal and CLI output.

```swift
let logger = Logger(configuration: LoggerConfiguration(
    subsystem: "com.example.cli",
    theme: .dracula,
    sinks: [
        StdoutSink()
    ]
))
```

Behavior:

- ANSI colors are enabled automatically in supported terminals
- ANSI is suppressed under Xcode to avoid escape-sequence noise

### `DebugConsoleSink`

Use this when you want the fully rendered line for a custom debug UI or local capture buffer.

```swift
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
- `networking`

Custom categories:

```swift
let payments = LoggerCategory(rawValue: "payments")
```

## Configuration

`LoggerConfiguration` controls:

- hard enable/disable behavior through `isEnabled`
- global minimum level
- per-category minimum levels
- enabled category filtering
- global allowed-level overrides
- file-based allowed-level overrides
- theme selection
- header formatting
- timestamp formatting
- line separators
- sink selection

### Example: category thresholds

```swift
let configuration = LoggerConfiguration(
    subsystem: "com.example.app",
    enabledCategories: [.debug, .networking],
    minimumLevel: .information,
    categoryLevels: [
        .debug: .simple,
        .networking: .warning
    ],
    theme: .defaultDark
)
```

### Example: file-based filtering

```swift
var configuration = LoggerConfiguration(subsystem: "com.example.app")
configuration.allowedLevelsByFile["PAYMENTSSERVICE.SWIFT"] = [.warning, .error]
```

### Example: custom formatting

```swift
let configuration = LoggerConfiguration(
    subsystem: "com.example.app",
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
```

## Environment Overrides

`LoggerConfiguration.applyingEnvironment(_:)` currently supports:

- `XCODELOGGER_LEVEL`
- `XCODELOGGER_CATEGORIES`
- `XCODELOGGER_ANSI`

These are runtime overrides. Build-configuration enablement should still live in app code via `LoggerBuildConfigurationProviding` or `isEnabled`.

## Legacy Compatibility

The Objective-C macro shim lives in `Compatibility/XcodeLogger.h`.

Compatibility calls route into the modern logger by category and level.

Built-in compatibility mapping:

- `XLog` -> `default`
- `DLog` -> `debug`
- `DVLog` -> `development`
- `DDLog` -> `debug-development`
- `NLog` -> `networking`

That mapping is part of the library's compatibility layer and does not need per-app customization.

The old scheme-name registration methods still exist for source compatibility, but they are intentionally inert in the Swift implementation because build behavior now belongs to the consuming app.

Example:

```swift
import XcodeLogger

XcodeLogger.shared.emitCompatibilityLog(
    type: .development,
    level: .information,
    file: "LegacyFile.m",
    function: "-[LegacyObject run]",
    line: 42,
    message: "Legacy compatibility output"
)
```

## Demos

- macOS app: `Examples/XcodeLoggerMacDemo.xcodeproj`
- iOS app: `Examples/XcodeLoggeriOSDemo.xcodeproj`
- terminal demo sources: `Examples/XcodeLoggerTerminalDemo`

Run the SwiftPM terminal demo:

```bash
swift run XcodeLoggerTerminalDemo
```

## Testing

Run the package test suite:

```bash
swift test
```
