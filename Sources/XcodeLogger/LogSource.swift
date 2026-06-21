import Foundation

public struct LogSource: Sendable, Equatable {
    public let file: String
    public let function: String
    public let line: Int

    public init(file: String = #fileID, function: String = #function, line: Int = #line) {
        self.file = file
        self.function = function
        self.line = line
    }

    public var fileName: String {
        URL(fileURLWithPath: file).lastPathComponent
    }
}
