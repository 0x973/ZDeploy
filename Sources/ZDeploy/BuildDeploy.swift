//
//  BuildDeploy.swift
//  ZDeploy
//
//  Created by Any on 2017/12/13.
//

import Foundation
import PerfectLib
import PerfectLogger

final class BuildDeploy:NSObject {
    // 单例模式
    static let shared = BuildDeploy()
    private override init() {}
    public var isDeploy = false
    
    public enum configuration: String {
        case debug = "debug"
        case release = "release"
    }
    
    let projectPath = workPath + "/" + projectName
    let config = configuration.release.rawValue
    
    // 编译服务!
    public func compile() {
        printLog(message: "编译函数")
        
        let shellString = String.init(format: "cd %@&&swift build -c %@", projectPath, config)
        Utils().executeShell(shellStr: shellString, success: { (res) in
            printLog(message: "编译成功")
            copyBinaryFile()
        }) { (err) in
            printLog(message: "编译失败!\(err)", type: .error)
        }
        
    }

    
    
    // 复制文件到指定的部署目录
    private func copyBinaryFile() {
        printLog(message: "复制编译完成的文件到指定部署目录中..")
        let path = String.init(format: "%@/.build/%@/", projectPath, config)
        File(path)
        
    }
    
    
    
    // 部署服务
    private func deploy() {
        
    }
    
    
    
}
