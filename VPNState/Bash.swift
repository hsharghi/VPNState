import Foundation

class Bash {
    static var debugEnabled = false

    // save command search time
    static var commandCache: [String: String] = [:]
    
    @discardableResult
    func run(_ command: String, arguments: [String] = [], environment: [String: String]? = ProcessInfo.processInfo.environment, _line: Int = #line) throws -> String {
        let _command: String
        if let cache = Bash.commandCache[command] {
            _command = cache
        } else {
            var theCommand = try run(command: "/bin/bash" , arguments: ["-l", "-c", "which \(command)"], environment: environment)
            theCommand = theCommand.trimmingCharacters(in: .whitespacesAndNewlines)
            _command = theCommand
            Bash.commandCache[command] = theCommand
        }
        let arguments = arguments.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let result = try run(command: _command, arguments: arguments, environment: environment)
        if Bash.debugEnabled {
            print("+\((#file as NSString).lastPathComponent):\(_line)> \(_command) \(arguments.joined(separator: " "))")
            print(result)
        }
        return result
    }
    
    private func run(command: String, arguments: [String] = [], environment: [String: String]? = nil) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: command)
        process.arguments = arguments
        if let environment = environment { process.environment = environment }
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        try process.run()
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        var output = String(decoding: outputData, as: UTF8.self)
        process.waitUntilExit()
        if output.hasSuffix("\n") {
            output.removeLast(1)
        }
        if process.terminationStatus != 0 { fatalError("shell execute coccus fail") }
        return output
    }
}
