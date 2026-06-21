public struct LoggerTheme: Sendable, Equatable {
    public struct Entry: Sendable, Equatable {
        public let label: String
        public let style: ANSIStyle?

        public init(label: String, style: ANSIStyle? = nil) {
            self.label = label
            self.style = style
        }
    }

    public let name: String
    private let entries: [LoggerLevel: Entry]

    public init(name: String, entries: [LoggerLevel: Entry]) {
        self.name = name
        self.entries = entries
    }

    public func entry(for level: LoggerLevel) -> Entry {
        entries[level] ?? Entry(label: level.defaultLabel)
    }

    public static let defaultLight = LoggerTheme(
        name: "DEFAULT_LIGHT_THEME",
        entries: [
            .simple: .init(label: "LOG", style: ANSIStyle(foreground: (52, 73, 94))),
            .simpleNoHeader: .init(label: "LOG", style: ANSIStyle(foreground: (52, 73, 94))),
            .information: .init(label: "INFO", style: ANSIStyle(foreground: (41, 128, 185))),
            .important: .init(label: "IMPORTANT", style: ANSIStyle(foreground: (142, 68, 173))),
            .warning: .init(label: "WARNING", style: ANSIStyle(foreground: (211, 84, 0))),
            .error: .init(label: "ERROR", style: ANSIStyle(foreground: (192, 57, 43)))
        ]
    )

    public static let defaultDark = LoggerTheme(
        name: "DEFAULT_DARK_THEME",
        entries: [
            .simple: .init(label: "LOG", style: ANSIStyle(foreground: (236, 240, 241))),
            .simpleNoHeader: .init(label: "LOG", style: ANSIStyle(foreground: (236, 240, 241))),
            .information: .init(label: "INFO", style: ANSIStyle(foreground: (52, 152, 219))),
            .important: .init(label: "IMPORTANT", style: ANSIStyle(foreground: (241, 196, 15))),
            .warning: .init(label: "WARNING", style: ANSIStyle(foreground: (230, 126, 34))),
            .error: .init(label: "ERROR", style: ANSIStyle(foreground: (231, 76, 60)))
        ]
    )

    public static let dracula = LoggerTheme(
        name: "DRACULA_THEME",
        entries: [
            .simple: .init(label: "LOG", style: ANSIStyle(foreground: (248, 248, 242))),
            .simpleNoHeader: .init(label: "LOG", style: ANSIStyle(foreground: (248, 248, 242))),
            .information: .init(label: "INFO", style: ANSIStyle(foreground: (139, 233, 253))),
            .important: .init(label: "IMPORTANT", style: ANSIStyle(foreground: (189, 147, 249))),
            .warning: .init(label: "WARNING", style: ANSIStyle(foreground: (255, 184, 108))),
            .error: .init(label: "ERROR", style: ANSIStyle(foreground: (255, 85, 85)))
        ]
    )

    public static let all: [String: LoggerTheme] = [
        defaultLight.name: .defaultLight,
        defaultDark.name: .defaultDark,
        dracula.name: .dracula
    ]
}
