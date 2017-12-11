//
//  Logger.swift
//  CloudPacker
//
//  Created by ZHENGSHOUDONG on 2017/11/7.
//

import Foundation
import PerfectLib

enum logType: String {
    case debug = "DEBUG"
    case info = "INFO"
    case error = "ERROR"
    case terminal = "TERMINAL"
}

private func filelog(priority: String, _ args: String, _ logFile: String, dateString:String) {
    let eventid = UUID().string
    var useFile = logFile
    if logFile.isEmpty { useFile = consoleLogFilePath }
    let ff = File(useFile)
    defer { ff.close() }
    do {
        try ff.open(.append)
        try ff.write(string: "\(priority) [\(eventid)] [\(dateString)] \(args)\n")
    } catch {
        print("[WRONG]\(error)")
    }
}

func printLog<T>(message: T,
                 line: Int = #line,
                 file: String = #file,
                 type: logType = .info,
                 method: String = #function) {
    autoreleasepool {
        
        let dateFormaterr = DateFormatter()
        dateFormaterr.dateStyle = .short
        dateFormaterr.timeStyle = .medium
        dateFormaterr.timeZone = TimeZone.current
        let dateString = dateFormaterr.string(from: Date())
        
        switch type {
        case .info:
            print("[\(type.rawValue)]\(dateString) \(message)")
            filelog(priority: "[\(type.rawValue)]", message as! String, consoleLogFilePath, dateString: dateString)
            break
        case .debug:
            print("[\(type.rawValue)]\(file.lastFilePathComponent)[\(line)], \(method): \(message)")
            filelog(priority: "[\(type.rawValue)]", message as! String, consoleLogFilePath, dateString: dateString)
            break
        case .error:
            print("[\(type.rawValue)]\(file.lastFilePathComponent)[\(line)], \(method): \(message)")
            filelog(priority: "[\(type.rawValue)]", message as! String, consoleLogFilePath, dateString: dateString)
            break
        case .terminal:
            print("[\(type.rawValue)]\(file.lastFilePathComponent)[\(line)], \(method): \(message)")
            filelog(priority: "[\(type.rawValue)]", message as! String, consoleLogFilePath, dateString: dateString)
            break
        }
        
    }
    
}
