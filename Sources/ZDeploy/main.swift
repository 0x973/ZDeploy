//
//  main.swift
//  ZDeploy
//
//  Created by ZHENGSHOUDONG on 2017/12/7.
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

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
        
        response.setBody(string: "{\"code\": 0}") // 部署服务空闲状态
        
        response.completed()
    }
}

func startDeploy(data: [String:Any]) throws -> RequestHandler {
    return {
        request, response in
        response.setHeader(.contentType, value: "application/json")
        response.status = .ok
        
        response.setBody(string: "")
        
        response.completed()
    }
}

func initZDeploy() -> Void {
    print("hello ZDeploy!")
    #if os(Linux)
        print("platform is not support!")
        exit(1)
    #endif
    
    let confData = [
        "servers": [
            [
                "name": "ZDeploy",
                "port": 9999,
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
