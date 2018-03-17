//
//  WebRequestHelper.swift
//  Jellyfish
//
//  Created by Yeung Yiu Hung on 13/3/2018.
//  Copyright © 2018 Jellyfish. All rights reserved.
//

import Foundation

func testingHost() -> String {
    return "http://localhost"
    
//    if let hostURL = ProcessInfo.processInfo.environment["HOST_URL"] {
//        print("Host: \(hostURL)")
//        return hostURL
//    }else{
//        return "http://localhost"
//    }
}

func checkTcpPortForListen(port: in_port_t) -> Bool{
    
    let socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0)
    if socketFileDescriptor == -1 {
        return false
    }
    
    var addr = sockaddr_in()
    addr.sin_len = __uint8_t(MemoryLayout<sockaddr_in>.size)
    addr.sin_family = sa_family_t(AF_INET)
    addr.sin_port = Int(OSHostByteOrder()) == OSLittleEndian ? _OSSwapInt16(port) : port
    addr.sin_addr = in_addr(s_addr: inet_addr("0.0.0.0"))
    addr.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)
    var bind_addr = sockaddr()
    memcpy(&bind_addr, &addr, Int(MemoryLayout<sockaddr_in>.size))
    
    if Darwin.bind(socketFileDescriptor, &bind_addr, socklen_t(MemoryLayout<sockaddr_in>.size)) == -1 {
        return false
    }
    if listen(socketFileDescriptor, SOMAXCONN ) == -1 {
        return false
    }
    return true
}

class WebRequestHelper {
    static func makeRequest(request: URLRequest, handler:@escaping ((Data?, URLResponse?, Error?) -> Void)) {
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            handler(data, response, error)
        }
        task.resume()
    }
}
