public protocol LoggerSink: AnyObject {
    var supportsANSIColors: Bool { get }
    func write(event: LogEvent, rendered: String)
}
