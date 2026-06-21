public struct LoggerFormatting: Sendable, Equatable {
    public var timestampFormat: String
    public var headerTokens: [HeaderToken]
    public var lineSeparatorAfterHeader: String
    public var lineSeparatorAfterMessage: String
    public var includeHeaderForSimpleLevel: Bool

    public init(
        timestampFormat: String = "HH:mm:ss.SSS",
        headerTokens: [HeaderToken] = [
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
        lineSeparatorAfterHeader: String = " ",
        lineSeparatorAfterMessage: String = "",
        includeHeaderForSimpleLevel: Bool = true
    ) {
        self.timestampFormat = timestampFormat
        self.headerTokens = headerTokens
        self.lineSeparatorAfterHeader = lineSeparatorAfterHeader
        self.lineSeparatorAfterMessage = lineSeparatorAfterMessage
        self.includeHeaderForSimpleLevel = includeHeaderForSimpleLevel
    }
}
