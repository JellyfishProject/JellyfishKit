//
//  Models.swift
//  Jellyfish
//
//  Created by Yeung Yiu Hung on 8/3/2018.
//  Copyright © 2018 Jellyfish. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case GET, POST, PUT, DELETE, UPDATE
    
    static func from(string: String) -> HTTPMethod {
        return HTTPMethod(rawValue: string) ?? .GET
    }
}

public struct APIRequest {
    public let headers: [String: String]?
    public let body: Data?
    public let method: HTTPMethod
    
    public init(headers: [String: String]?, body: Data?, method: HTTPMethod) {
        self.headers = headers
        self.body = body
        self.method = method
    }
}

public struct APIResponse {
    public let headers: [String: String]?
    public let responseCode: Int?
    public let body: Data?
    
    public init(headers: [String: String]?, responseCode: Int?, body: Data?) {
        self.headers = headers
        self.responseCode = responseCode
        self.body = body
    }
}

public struct APIExample {
    let pathParams: [String: String]
    let queryParams: [String: String]
    let requests: [APIRequest]
    let responses: [APIResponse]
}

public struct APIResource {
    let path: String
    let examples: [APIExample]
}

public struct APIDefinition {
    let title: String
    let host: String
    
    let resources: [APIResource]
}
