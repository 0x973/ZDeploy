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
            do {
                try FileManager.default.removeItem(atPath: projectPath)
            }catch{
                printLog(message: error, type: .error)
            }
        }) { (err) in
            printLog(message: "编译失败!\(err)", type: .error)
        }
    }
    
    
    
    // 复制文件到指定的部署目录
    private func copyBinaryFile() {
        printLog(message: "复制编译完成的文件到指定部署目录中..")
        let path = String.init(format: "%@/.build/%@/%@", projectPath, config, name)
        if File(path).exists {
            // 文件存在可以尝试部署
            do {
                try File(path).copyTo(path: deployPath)
                deploy()
            }catch {
                printLog(message: error, type: .error)
            }
        }else {
            // 文件不存在,无法完成部署
            printLog(message: "编译的二进制文件不存在,请检查是否编译成功!", type: .error)
        }
    }
    
    // 部署服务
    private func deploy() {
        print("开始正式部署新的二进制文件!")
        
    }
    
    
    
}
