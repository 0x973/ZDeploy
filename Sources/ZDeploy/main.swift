//
//  main.swift
//  ZDeploy
//
//  Created by ZHENGSHOUDONG on 2017/12/7.
//

import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

let empty = ""
let workPath = NSHomeDirectory() + "/.ZDeploy"
let configFilePath = workPath + "/config.json"
let consoleLogFilePath = workPath + "/consoleLog.log"
var port = 9999

var repository = empty // 仓库地址,用于拉取代码
var deployPath = empty  // 部署路径
var projectName = empty  // 项目名,不需要外部传入自动根据传入仓库地址计算

func handler(data: [String:Any]) throws -> RequestHandler {
    return {
        request, response in
        response.setHeader(.contentType, value: "text/html")
        response.status = .ok
        response.setBody(string: "<html><meta charset='utf-8'><meta name='viewport' content='width=device-width, initial-scale=1'><title>Hello,ZDeploy!</title><body><div><center><p style='font-size:xx-large;'>ZDeploy</p><p style='font-size:large;'>version: 1.0.0</p></center></div></body></html>")
        response.appendBody(string: "<div style='position:absolute;bottom:15px;right:10px;font-size:x-small;text-align: right;'><p>ZHENGSHOUDONG</p><p>2017-12</p></div>")
        response.completed()
    }
}

func statusHandler(data: [String:Any]) throws -> RequestHandler {
    return {
        request, response in
        response.setHeader(.contentType, value: "application/json")
        response.status = .ok
        
        response.setBody(string: "{\"code\": 0}") // 空闲状态
        response.setBody(string: "{\"code\": 1}") // 部署中
        
        response.completed()
    }
}

func startDeploy(data: [String:Any]) throws -> RequestHandler {
    return {
        request, response in
        response.setHeader(.contentType, value: "application/json")
        response.status = .ok
        let body = request.postBodyString ?? empty
        print(body)
        let json = JSON.init(parseJSON: body)
        
        repository = json["repository"].string ?? empty
        
        print(repository)
        
        deployPath = json["deployPath"].string ?? empty
        
        print(deployPath)
        
        projectName = Utils().getProjectName(gitLocation: repository)
        
        if BuildDeploy.shared.isDeploy {
            // 正在部署中
            response.setBody(string: "{\"code\": 1,\"msg\": \"busy\"}")
        }else {
            // 服务空闲
            response.setBody(string: "{\"code\": 0,\"msg\": \"start task\"}")
        }
        
        response.completed()
    }
}

func initZDeploy() -> Void {
    print("Hello ZDeploy!")
    #if os(Linux)
        print("platform is not support!")
        exit(1)
    #endif
    
    if File(configFilePath).exists {
        do {
            let configJson = try String.init(contentsOfFile: configFilePath, encoding: .utf8)
            if configJson.isEmpty {
                printLog(message: "The file config.json content is empty!", type: .error)
                exit(1)
            }
            let configDict = JSON.init(parseJSON: configJson)
            if configDict.isEmpty {
                printLog(message: "The file config.json content is wrong!", type: .error)
                exit(1)
            }
            port = configDict["port"].int ?? port
        }catch {
            printLog(message: "\(error)", type: .error)
            exit(1)
        }
    }else {
        do {
            try Dir(workPath).create()
            let str = String.init(format: "{\"port\": %d}", port)
            try str.write(toFile: configFilePath , atomically: true, encoding: .utf8)
            printLog(message: " file config.json is not exist!The file was auto created!", type: .error)
            initZDeploy()
            return
        }catch {
            printLog(message: "\(error)", type: .error)
            exit(1)
        }
    }
    
    let confData = [
        "servers": [
            [
                "name": "ZDeploy",
                "port": port,
                "routes":[
                    ["method":"get", "uri":"/", "handler":handler],
                    ["method":"get", "uri":"/status", "handler":statusHandler],
                    ["method":"post", "uri":"/deploy", "handler":startDeploy],
                ],
                "filters":[
                    ["type":"response",
                     "priority":"high",
                     "name":PerfectHTTPServer.HTTPFilter.contentCompression,
                     ]
                ]
            ]
        ]
    ]
    do {
        try HTTPServer.launch(configurationData: confData)
    } catch {
        fatalError("\(error)")
    }
}

initZDeploy()
