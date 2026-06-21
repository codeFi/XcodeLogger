# XcodeLogger

`XcodeLogger 2.2.0` is the Swift-first replacement for the legacy Objective-C Xcode Logger project.

This version keeps the familiar ideas:

- readable developer-focused log output
- compatibility routing for `XLog`, `DLog`, `DVLog`, `DDLog`, and `NLog`
- file-level and global level filtering

It deliberately changes one important architectural point from the legacy project:

- build-configuration behavior is no longer encoded inside `XcodeLogger`
- your app owns that decision in its own source using compile-time conditions such as `#if DEBUG`
- `XcodeLogger` only consumes the result as a safe on/off policy

That is the main migration path away from the old Info.plist scheme-linking model.

## 2.2 Update

Version `2.2.0` expands the Swift package around a synchronous core and asynchronous sink delivery model.

- scoped child loggers through `category(_:)` and `scoped(...)`
- per-sink policy for minimum levels, regex category rules, file overrides, sampling, and rate limiting
- redaction for metadata keys and message bodies before sink rendering
- async-capable sinks with a shared serial delivery coordinator for deterministic ordering
- new `FileSink` with size-based rotation and archive retention
- shipped `TestSink` for package consumers writing logger tests
- simplified build gating with `LoggerConfiguration.whenEnabled(_:)`
- legacy Objective-C implementation tree removed from the repository, while `Compatibility/XcodeLogger.h` remains supported

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
    .package(url: "https://github.com/codeFi/XcodeLogger.git", from: "2.2.0")
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

## 2.2 Usage Guide

The new 2.2 features are meant to compose:

- create scoped child loggers once, then reuse them
- keep caller-side logging cheap by making non-interactive sinks asynchronous
- apply redaction globally so every sink receives the same sanitized event
- use per-sink policy to keep each output useful instead of forcing one global threshold

### Example: scoped child loggers

Use child loggers when a subsystem, category, or metadata set repeats across a workflow.

```swift
let paymentsLogger = logger
    .scoped(subsystem: "com.example.app.payments")
    .category("payments")
    .scoped(metadata: [
        "flow": "checkout",
        "screen": "payment-sheet"
    ])

paymentsLogger.log(
    level: .information,
    message: "Starting authorization",
    metadata: ["requestID": "req-42"]
)

paymentsLogger.log(
    level: .error,
    message: "Authorization failed",
    metadata: ["requestID": "req-42", "attempt": "2"]
)
```

Guidelines:

- prefer child loggers for stable context like feature area, flow, or subsystem
- use per-call metadata for short-lived values like request IDs or retry counts
- later scopes override earlier metadata for the same key

### Example: build enablement with `whenEnabled(_:)`

Use `whenEnabled(_:)` when you already know the final compile-time decision and do not need a provider type.

```swift
let configuration = LoggerConfiguration(subsystem: "com.example.app")
    .whenEnabled({
        #if DEBUG
        true
        #else
        false
        #endif
    }())
```

### Example: redaction

Redaction runs before any sink renders output.

```swift
let configuration = LoggerConfiguration(
    subsystem: "com.example.app",
    metadataRedactionRules: [
        LoggerMetadataRedactionRule(key: "token"),
        LoggerMetadataRedactionRule(key: "email", replacement: "<redacted-email>")
    ],
    messageRedactors: [
        LoggerMessageRedactor { message in
            message.replacingOccurrences(of: "4111 1111 1111 1111", with: "<card>")
        }
    ]
)
```

Guidelines:

- redact by metadata key for stable fields like `token`, `email`, or `sessionID`
- use message redactors for free-form strings coming from APIs or user input
- treat redaction as global policy, not sink-specific formatting

### Example: per-sink policy

Different sinks usually need different noise levels.

```swift
let consoleSink = DebugConsoleSink(
    policy: LoggerSinkPolicy(
        minimumLevel: .information,
        categoryRules: [
            LoggerCategoryRule(pattern: "^network", mode: .allow),
            LoggerCategoryRule(pattern: "verbose", mode: .deny)
        ]
    )
)

let fileSink = FileSink(
    fileURL: URL(fileURLWithPath: "/tmp/app.log"),
    maximumFileSizeInBytes: 512_000,
    maximumArchiveCount: 3,
    policy: LoggerSinkPolicy(
        minimumLevel: .simple,
        allowedLevelsByFile: [
            "PAYMENTSSERVICE.SWIFT": [.warning, .error]
        ]
    )
)
```

Guidelines:

- use stricter console policies so developers only see actionable output
- keep file sinks broader when they serve post-failure diagnosis
- invalid regex rules are ignored, so validate patterns in tests if they matter

### Example: sampling and rate limiting

Use sink policy to suppress very noisy categories without disabling them globally.

```swift
let sink = DebugConsoleSink(
    policy: LoggerSinkPolicy(
        samplingRules: [
            LoggerSamplingRule(category: .debug, probability: 0.2)
        ],
        rateLimitRules: [
            LoggerRateLimitRule(category: .networking, maximumEvents: 20, window: 60)
        ]
    )
)
```

Guidelines:

- use sampling for high-volume debug traces where representative coverage is enough
- use rate limiting for bursty operational categories like networking or retries
- suppressed events are dropped silently in 2.2, so avoid aggressive policies for critical categories

### Example: async delivery and file rotation

Async delivery is opt-in per sink. It is the default choice for sinks that touch the filesystem.

```swift
let fileSink = FileSink(
    fileURL: URL(fileURLWithPath: "/var/tmp/example.log"),
    maximumFileSizeInBytes: 1_048_576,
    maximumArchiveCount: 5,
    append: true,
    deliveryMode: .asynchronous(batchSize: 16)
)

let logger = Logger(configuration: LoggerConfiguration(
    subsystem: "com.example.app",
    sinks: [
        OSLogSink(subsystem: "com.example.app"),
        fileSink
    ]
))
```

Guidelines:

- keep `OSLogSink` synchronous for immediate system integration
- prefer async delivery for file or custom sinks that may block
- start with small batch sizes like `8` or `16` unless you have measured a need for more
- rotation archives use stable numbered suffixes such as `example.1.log`

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

### `FileSink`

Use this for persistent local capture with size-based rotation.

```swift
let logger = Logger(configuration: LoggerConfiguration(
    subsystem: "com.example.app",
    sinks: [
        FileSink(
            fileURL: URL(fileURLWithPath: "/tmp/example.log"),
            maximumFileSizeInBytes: 512_000,
            maximumArchiveCount: 3
        )
    ]
))
```

Behavior:

- writes append by default
- file delivery is intended to be asynchronous
- archives rotate to numbered siblings like `example.1.log`, `example.2.log`

### `TestSink`

Use this in your own tests instead of building an ad hoc sink for every suite.

```swift
let sink = TestSink()
let logger = Logger(configuration: LoggerConfiguration(
    subsystem: "com.example.tests",
    sinks: [sink]
))

logger.log(level: .warning, category: .networking, message: "captured")

XCTAssertEqual(sink.events.first?.category, .networking)
XCTAssertTrue(sink.renderedMessages.first?.contains("captured") == true)
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
