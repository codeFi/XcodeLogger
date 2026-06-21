import Foundation

struct LoggerFormatter {
    private let dateFormatterCache = NSCache<NSString, DateFormatter>()

    func render(event: LogEvent, configuration: LoggerConfiguration, includeANSI: Bool) -> String {
        let themeEntry = configuration.theme.entry(for: event.level)
        let header = renderHeader(event: event, configuration: configuration, label: themeEntry.label)
        let body = includeANSI ? themeEntry.style?.applying(to: event.message) ?? event.message : event.message

        if header.isEmpty {
            return body + configuration.formatting.lineSeparatorAfterMessage
        }

        return header + configuration.formatting.lineSeparatorAfterHeader + body + configuration.formatting.lineSeparatorAfterMessage
    }

    func renderStructuredMessage(for event: LogEvent) -> String {
        var components = ["[\(event.level.defaultLabel)]", event.message]
        if !event.metadata.isEmpty {
            let metadata = event.metadata
                .sorted(by: { $0.key < $1.key })
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: ",")
            components.append("{\(metadata)}")
        }
        return components.joined(separator: " ")
    }
}

extension LoggerFormatter {
    private func renderHeader(event: LogEvent, configuration: LoggerConfiguration, label: String) -> String {
        let formatting = configuration.formatting
        if event.level == .simpleNoHeader {
            return ""
        }
        if event.level == .simple && !formatting.includeHeaderForSimpleLevel {
            return ""
        }

        var result = ""
        for token in formatting.headerTokens {
            switch token {
            case .label:
                result += label
            case .timestamp:
                result += formatter(for: formatting.timestampFormat).string(from: event.timestamp)
            case .category:
                result += event.category.rawValue
            case .file:
                result += event.source.fileName
            case .function:
                result += event.source.function
            case .line:
                result += "\(event.source.line)"
            case .metadata:
                let metadata = event.metadata
                    .sorted(by: { $0.key < $1.key })
                    .map { "\($0.key)=\($0.value)" }
                    .joined(separator: ", ")
                result += metadata
            case let .literal(string):
                result += string
            }
        }
        return result
    }

    private func formatter(for format: String) -> DateFormatter {
        if let cached = dateFormatterCache.object(forKey: format as NSString) {
            return cached
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format
        dateFormatterCache.setObject(formatter, forKey: format as NSString)
        return formatter
    }
}
