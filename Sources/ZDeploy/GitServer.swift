//
//  gitServer.swift
//  Kedar
//
//  Created by ZHENGSHOUDONG on 2017-09-05.
//    Copyright (C) 2017 ZHENGSHOUDONG.
//
//===----------------------------------------------------------------------===//
//

import Foundation
import PerfectLib

public class GitServer {
    
    private var retryCount = 0
    private let gitVerShellStr = "git --version"
    
    public func main() {
        let isDeploy = BuildDeploy.shared.isDeploy
        
        if !isDeploy {
            if !isInstallGit() {
                printLog(message: "please install git!" , type:.error)
            }else {
                let projectPath = workPath + "/" + projectName
                if !Dir(projectPath).exists {
                    // 仓库不存在,克隆(需要自行保证服务器有权限克隆)
                    print("[INFO]Project is not clone!")
                    print("[INFO]cloning..")
                    let cloneStatus = cloneServer()
                    if cloneStatus {
                        //克隆成功
                        print("[INFO]Clone success!")
                        retryCount = 0
                        BuildDeploy.shared.compile()
                    }else {
                        //克隆失败
                        print("[INFO]Clone failed!")
                    }
                }else {
                    // 仓库已经存在
                    let pullStatus = pullServer()
                    if pullStatus {
                        //拉取成功
                        print("[INFO]Pull success!")
                        retryCount = 0
                        BuildDeploy.shared.compile()
                        
                    }else {
                        //拉取失败
                        print("[INFO]Pull failed!")
                        if Dir(projectPath).exists {
                            try? FileManager.default.removeItem(atPath: projectPath)
                        }
                        if retryCount <= 3 {
                            main()
                        }
                        retryCount += retryCount
                    }
                }
            }
        }
    }
    
    private func pullServer() -> Bool {
        let path = workPath + "/" + projectName
        var pullSuccess = false
        Utils().executeShell(shellStr: String.init(format: "cd %@&&git pull", path), success: { (ret) in
            pullSuccess = true
        }, failed: { (err) in
            pullSuccess = false
            print(err.description)
        })
        return pullSuccess
    }
    
    private func cloneServer() -> Bool {
        var cloneSuccess = false
        Utils().executeShell(shellStr: String.init(format: "cd %@&&git clone %@", workPath, repository), success: { (ret) in
            cloneSuccess = true
        }, failed: { (err) in
            cloneSuccess = false
            print(err.description)
        })
        return cloneSuccess
    }
    
    private func isInstallGit() -> Bool {
        var isInstallGit = false
        Utils().executeShell(shellStr: gitVerShellStr, success: { (ret) in
            isInstallGit = true
        }) { (err) in
            isInstallGit = false
            print(err.description)
        }
        return isInstallGit
    }
    
}

