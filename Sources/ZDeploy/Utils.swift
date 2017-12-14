//
//  Utils.swift
//  ZDeploy
//
//  Created by Any on 2017/12/13.
//

import Foundation
import PerfectLib

class Utils {
    
    public func executeShell(shellStr: String, success: (String) -> (), failed: (NSDictionary) -> () ) {
        if shellStr.isEmpty {
            failed(["err": "str is empty!"])
            return
        }
        var eventDescriptor = NSAppleEventDescriptor.init()
        var script = NSAppleScript.init()
        var error: NSDictionary? = NSDictionary.init()
        
        let scriptSource = String.init(format: "do shell script \"%@\"", shellStr)
        if !scriptSource.isEmpty {
            script = NSAppleScript.init(source: scriptSource)!
            
            eventDescriptor = script.executeAndReturnError(&error)
            
            if (error!.count > 0) {
                //                print("错误信息:\(error!)")
                failed(error!)
            }else {
                let info = eventDescriptor.stringValue ?? ""
                //                print("正常!脚本运行信息:" + info)
                success(info)
            }
        }
    }
    
    
    /// 字符串处理
    ///
    /// - Parameter gitLocation: Input:"https://github.com/ZhengShouDong/CloudPacker.git"
    /// - Returns: Output:"CloudPacker"
    public func getProjectName(gitLocation: String) -> String {
        guard !gitLocation.isEmpty else { return empty }
        let gitL = gitLocation.replacingOccurrences(of: " ", with: "")
        let arr = gitL.split(separator: "/")
        var name = arr[arr.count - 1].description
        name = name.replacingOccurrences(of: ".git", with: "")
        return name
    }
    
    
    
    
}
